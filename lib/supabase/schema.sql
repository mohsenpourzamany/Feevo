-- ══════════════════════════════════════════════════════════════════════════════
-- Feevo — Supabase Database Schema
-- Run this in your Supabase SQL Editor (Dashboard → SQL Editor → New Query)
-- ══════════════════════════════════════════════════════════════════════════════

-- Enable required extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ─── 1. Users ─────────────────────────────────────────────────────────────────

create table if not exists public.users (
  id            uuid primary key references auth.users(id) on delete cascade,
  email         text unique not null,
  name          text not null default '',
  username      text unique not null,
  bio           text,
  avatar_url    text,
  is_premium    boolean not null default false,
  premium_until timestamptz,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- Auto-update updated_at
create or replace function public.handle_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger users_updated_at
  before update on public.users
  for each row execute function public.handle_updated_at();

-- Auto-create user row when someone signs up via Supabase Auth
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.users (id, email, name, username)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(
      new.raw_user_meta_data->>'username',
      'user_' || substring(new.id::text, 1, 8)
    )
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ─── 2. Tracks ────────────────────────────────────────────────────────────────

create table if not exists public.tracks (
  id           uuid primary key default uuid_generate_v4(),
  spotify_id   text unique,
  title        text not null,
  artist       text not null,
  artist_id    text,            -- Spotify artist ID
  album        text,
  album_art    text,            -- Cover image URL
  duration_ms  integer,
  preview_url  text,
  popularity   integer default 0,
  created_at   timestamptz not null default now()
);

create index if not exists tracks_spotify_id_idx on public.tracks(spotify_id);

-- ─── 3. Playlists ─────────────────────────────────────────────────────────────

create table if not exists public.playlists (
  id              uuid primary key default uuid_generate_v4(),
  user_id         uuid not null references public.users(id) on delete cascade,
  name            text not null,
  description     text,
  cover_url       text,
  is_public       boolean not null default true,
  is_ai_generated boolean not null default false,
  mood_tag        text,         -- e.g. 'melancholic', 'energetic'
  track_count     integer not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create trigger playlists_updated_at
  before update on public.playlists
  for each row execute function public.handle_updated_at();

create index if not exists playlists_user_id_idx on public.playlists(user_id);

-- ─── 4. Playlist Tracks ───────────────────────────────────────────────────────

create table if not exists public.playlist_tracks (
  playlist_id uuid not null references public.playlists(id) on delete cascade,
  track_id    uuid not null references public.tracks(id) on delete cascade,
  position    integer not null default 0,
  added_at    timestamptz not null default now(),
  primary key (playlist_id, track_id)
);

create index if not exists pt_playlist_id_idx on public.playlist_tracks(playlist_id);

-- Auto-update track_count on playlists
create or replace function public.update_playlist_track_count()
returns trigger language plpgsql as $$
begin
  if TG_OP = 'INSERT' then
    update public.playlists
    set track_count = track_count + 1
    where id = new.playlist_id;
  elsif TG_OP = 'DELETE' then
    update public.playlists
    set track_count = greatest(track_count - 1, 0)
    where id = old.playlist_id;
  end if;
  return null;
end;
$$;

create trigger playlist_tracks_count
  after insert or delete on public.playlist_tracks
  for each row execute function public.update_playlist_track_count();

-- ─── 5. Liked Songs ───────────────────────────────────────────────────────────

create table if not exists public.liked_songs (
  user_id    uuid not null references public.users(id) on delete cascade,
  track_id   uuid not null references public.tracks(id) on delete cascade,
  liked_at   timestamptz not null default now(),
  primary key (user_id, track_id)
);

create index if not exists liked_songs_user_id_idx on public.liked_songs(user_id);

-- ─── 6. Memories (play history with mood) ────────────────────────────────────

create table if not exists public.memories (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references public.users(id) on delete cascade,
  track_id    uuid not null references public.tracks(id) on delete cascade,
  play_count  integer not null default 1,
  mood        text,             -- 'happy', 'sad', 'energetic', 'calm', etc.
  time_of_day text,             -- 'morning', 'afternoon', 'evening', 'night'
  lat         double precision, -- Optional location
  lng         double precision,
  last_played timestamptz not null default now(),
  created_at  timestamptz not null default now(),
  unique (user_id, track_id)
);

create index if not exists memories_user_id_idx on public.memories(user_id);
create index if not exists memories_last_played_idx on public.memories(last_played desc);

-- ─── 7. Live Rooms ────────────────────────────────────────────────────────────

create table if not exists public.live_rooms (
  id             uuid primary key default uuid_generate_v4(),
  host_id        uuid not null references public.users(id) on delete cascade,
  name           text not null,
  vibe           text,          -- 'chill', 'party', 'focus', etc.
  current_track  uuid references public.tracks(id),
  is_active      boolean not null default true,
  listener_count integer not null default 0,
  max_listeners  integer not null default 50,
  created_at     timestamptz not null default now(),
  ended_at       timestamptz
);

create index if not exists live_rooms_is_active_idx on public.live_rooms(is_active);
create index if not exists live_rooms_host_id_idx on public.live_rooms(host_id);

-- ─── 8. Room Participants ─────────────────────────────────────────────────────

create table if not exists public.room_participants (
  room_id    uuid not null references public.live_rooms(id) on delete cascade,
  user_id    uuid not null references public.users(id) on delete cascade,
  joined_at  timestamptz not null default now(),
  primary key (room_id, user_id)
);

-- ─── 9. Room Messages ─────────────────────────────────────────────────────────

create table if not exists public.room_messages (
  id         uuid primary key default uuid_generate_v4(),
  room_id    uuid not null references public.live_rooms(id) on delete cascade,
  user_id    uuid not null references public.users(id) on delete cascade,
  message    text not null,
  created_at timestamptz not null default now()
);

create index if not exists room_messages_room_id_idx on public.room_messages(room_id);

-- ══════════════════════════════════════════════════════════════════════════════
-- Row Level Security (RLS)
-- ══════════════════════════════════════════════════════════════════════════════

alter table public.users enable row level security;
alter table public.tracks enable row level security;
alter table public.playlists enable row level security;
alter table public.playlist_tracks enable row level security;
alter table public.liked_songs enable row level security;
alter table public.memories enable row level security;
alter table public.live_rooms enable row level security;
alter table public.room_participants enable row level security;
alter table public.room_messages enable row level security;

-- Users: read all, write own
create policy "Users: read all"     on public.users for select using (true);
create policy "Users: update own"   on public.users for update using (auth.uid() = id);

-- Tracks: read all (public music data), insert for authenticated
create policy "Tracks: read all"    on public.tracks for select using (true);
create policy "Tracks: insert auth" on public.tracks for insert with check (auth.uid() is not null);

-- Playlists: read public + own private, full CRUD own
create policy "Playlists: read public or own"
  on public.playlists for select
  using (is_public = true or user_id = auth.uid());
create policy "Playlists: insert own" on public.playlists for insert with check (user_id = auth.uid());
create policy "Playlists: update own" on public.playlists for update using (user_id = auth.uid());
create policy "Playlists: delete own" on public.playlists for delete using (user_id = auth.uid());

-- Playlist tracks: follow parent playlist policy
create policy "PT: read if playlist readable"
  on public.playlist_tracks for select
  using (
    exists (
      select 1 from public.playlists p
      where p.id = playlist_id
        and (p.is_public = true or p.user_id = auth.uid())
    )
  );
create policy "PT: manage own playlist" on public.playlist_tracks
  for all using (
    exists (
      select 1 from public.playlists p
      where p.id = playlist_id and p.user_id = auth.uid()
    )
  );

-- Liked songs: own only
create policy "Liked: own only" on public.liked_songs
  for all using (user_id = auth.uid());

-- Memories: own only
create policy "Memories: own only" on public.memories
  for all using (user_id = auth.uid());

-- Live rooms: read active, manage own
create policy "Rooms: read active" on public.live_rooms for select using (is_active = true);
create policy "Rooms: insert auth"  on public.live_rooms for insert with check (host_id = auth.uid());
create policy "Rooms: update own"   on public.live_rooms for update using (host_id = auth.uid());

-- Room participants: read all in room, manage own
create policy "Participants: read"   on public.room_participants for select using (true);
create policy "Participants: manage" on public.room_participants for all using (user_id = auth.uid());

-- Room messages: read all in room, insert own
create policy "Messages: read"   on public.room_messages for select using (true);
create policy "Messages: insert" on public.room_messages for insert with check (user_id = auth.uid());

-- ══════════════════════════════════════════════════════════════════════════════
-- Realtime: enable for live rooms feature
-- ══════════════════════════════════════════════════════════════════════════════

alter publication supabase_realtime add table public.live_rooms;
alter publication supabase_realtime add table public.room_messages;
alter publication supabase_realtime add table public.room_participants;
