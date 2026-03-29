-- TradePulse AI - SQL para Supabase
-- Rode este script inteiro no SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.signals (
  id uuid primary key default gen_random_uuid(),
  pair text not null,
  signal text not null check (signal in ('COMPRA', 'VENDA')),
  score numeric(5,2) not null,
  confidence numeric(4,2) not null check (confidence >= 0 and confidence <= 1),
  risk text not null check (risk in ('BAIXO', 'MÉDIO', 'ALTO')),
  reason text not null,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.backtests (
  id uuid primary key default gen_random_uuid(),
  pair text not null,
  hit_rate numeric(5,2) not null,
  loss_rate numeric(5,2) not null,
  profit_percent numeric(6,2) not null,
  drawdown_percent numeric(6,2) not null,
  risk_return numeric(6,2) not null,
  tested_at timestamptz not null default timezone('utc', now())
);

alter table public.profiles enable row level security;
alter table public.signals enable row level security;
alter table public.backtests enable row level security;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email)
  on conflict (id) do update set email = excluded.email;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- policies: profiles

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
  on public.profiles
  for select
  to authenticated
  using (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles
  for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- policies: signals

drop policy if exists "signals_read_authenticated" on public.signals;
create policy "signals_read_authenticated"
  on public.signals
  for select
  to authenticated
  using (true);

-- policies: backtests

drop policy if exists "backtests_read_authenticated" on public.backtests;
create policy "backtests_read_authenticated"
  on public.backtests
  for select
  to authenticated
  using (true);

-- Seed inicial
insert into public.signals (pair, signal, score, confidence, risk, reason)
values
  ('BTC/USD', 'COMPRA', 0.89, 0.75, 'MÉDIO', 'MACD cruzado, aumento de volume e RSI neutro'),
  ('ETH/USD', 'VENDA', -0.66, 0.64, 'ALTO', 'Volume inesperado e MACD negativo'),
  ('SOL/USD', 'COMPRA', 0.53, 0.61, 'BAIXO', 'Reteste de suporte com força compradora')
on conflict do nothing;

insert into public.backtests (pair, hit_rate, loss_rate, profit_percent, drawdown_percent, risk_return)
values
  ('BTC/USD', 65.00, 35.00, 18.40, 6.20, 2.30),
  ('ETH/USD', 58.00, 42.00, 11.70, 8.90, 1.70),
  ('SOL/USD', 62.00, 38.00, 14.10, 5.80, 2.10)
on conflict do nothing;
