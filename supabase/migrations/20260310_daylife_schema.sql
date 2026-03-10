-- DAYLIFE (30,000 Days) - Complete Database Schema
-- Run this in Supabase SQL Editor

-- ============================================================
-- 1. Create user_profiles table (base + DAYLIFE extensions)
-- ============================================================

CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  date_of_birth DATE,
  display_name TEXT,
  profile_photo_url TEXT,
  dicebear_seed TEXT,
  dicebear_style TEXT DEFAULT 'adventurer',
  total_stars INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_login_date DATE,
  preferred_language TEXT DEFAULT 'en',
  theme_preference TEXT DEFAULT 'dark',
  onboarding_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own_profile" ON public.user_profiles
  FOR SELECT TO authenticated USING (id = auth.uid());
CREATE POLICY "users_update_own_profile" ON public.user_profiles
  FOR UPDATE TO authenticated USING (id = auth.uid()) WITH CHECK (id = auth.uid());
CREATE POLICY "users_insert_own_profile" ON public.user_profiles
  FOR INSERT TO authenticated WITH CHECK (id = auth.uid());

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- 2. Dreams table
-- ============================================================

CREATE TABLE IF NOT EXISTS public.dreams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT DEFAULT 'general',
  color_hex TEXT DEFAULT '#C0C0C0',
  deadline DATE,
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_dreams_user_id ON public.dreams(user_id);
CREATE INDEX IF NOT EXISTS idx_dreams_user_completed ON public.dreams(user_id, is_completed);

ALTER TABLE public.dreams ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own_dreams" ON public.dreams
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "users_insert_own_dreams" ON public.dreams
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "users_update_own_dreams" ON public.dreams
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "users_delete_own_dreams" ON public.dreams
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- ============================================================
-- 3. Reflections table
-- ============================================================

CREATE TABLE IF NOT EXISTS public.reflections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  reflection_date DATE NOT NULL DEFAULT CURRENT_DATE,
  learned TEXT,
  grateful TEXT,
  improve TEXT,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT unique_reflection_per_day UNIQUE(user_id, reflection_date)
);

CREATE INDEX IF NOT EXISTS idx_reflections_user_date ON public.reflections(user_id, reflection_date DESC);

ALTER TABLE public.reflections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own_reflections" ON public.reflections
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "users_insert_own_reflections" ON public.reflections
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "users_update_own_reflections" ON public.reflections
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "users_delete_own_reflections" ON public.reflections
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- ============================================================
-- 4. Star transactions table
-- ============================================================

CREATE TABLE IF NOT EXISTS public.star_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  amount INTEGER NOT NULL,
  reason TEXT NOT NULL,
  reference_type TEXT,
  reference_id UUID,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_star_transactions_user ON public.star_transactions(user_id, created_at DESC);

ALTER TABLE public.star_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own_stars" ON public.star_transactions
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "users_insert_own_stars" ON public.star_transactions
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

-- ============================================================
-- 5. Daily logins table
-- ============================================================

CREATE TABLE IF NOT EXISTS public.daily_logins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  login_date DATE NOT NULL DEFAULT CURRENT_DATE,
  stars_awarded INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT unique_daily_login UNIQUE(user_id, login_date)
);

CREATE INDEX IF NOT EXISTS idx_daily_logins_user_date ON public.daily_logins(user_id, login_date DESC);

ALTER TABLE public.daily_logins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own_logins" ON public.daily_logins
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "users_insert_own_logins" ON public.daily_logins
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

-- ============================================================
-- 6. User unlocks table
-- ============================================================

CREATE TABLE IF NOT EXISTS public.user_unlocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  unlock_type TEXT NOT NULL,
  unlock_key TEXT NOT NULL,
  unlocked_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT unique_unlock UNIQUE(user_id, unlock_type, unlock_key)
);

ALTER TABLE public.user_unlocks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own_unlocks" ON public.user_unlocks
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "users_insert_own_unlocks" ON public.user_unlocks
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

-- ============================================================
-- 7. Database functions
-- ============================================================

CREATE OR REPLACE FUNCTION public.record_daylife_login(p_user_id UUID)
RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_last_login DATE;
  v_new_streak INTEGER;
  v_stars_to_award INTEGER := 1;
  v_streak_bonus INTEGER := 0;
  v_login_exists BOOLEAN;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM public.daily_logins
    WHERE user_id = p_user_id AND login_date = CURRENT_DATE
  ) INTO v_login_exists;

  IF v_login_exists THEN
    RETURN jsonb_build_object('already_logged', true, 'stars_awarded', 0, 'streak_bonus', 0,
      'current_streak', (SELECT current_streak FROM public.user_profiles WHERE id = p_user_id),
      'total_stars', (SELECT total_stars FROM public.user_profiles WHERE id = p_user_id));
  END IF;

  SELECT last_login_date INTO v_last_login FROM public.user_profiles WHERE id = p_user_id;

  IF v_last_login = CURRENT_DATE - INTERVAL '1 day' THEN
    SELECT current_streak + 1 INTO v_new_streak FROM public.user_profiles WHERE id = p_user_id;
  ELSE
    v_new_streak := 1;
  END IF;

  IF v_new_streak > 0 AND v_new_streak % 7 = 0 THEN
    v_streak_bonus := 10;
  END IF;

  INSERT INTO public.daily_logins (user_id, login_date, stars_awarded)
  VALUES (p_user_id, CURRENT_DATE, v_stars_to_award + v_streak_bonus);

  INSERT INTO public.star_transactions (user_id, amount, reason, reference_type)
  VALUES (p_user_id, v_stars_to_award, 'daily_login', 'login');

  IF v_streak_bonus > 0 THEN
    INSERT INTO public.star_transactions (user_id, amount, reason, reference_type)
    VALUES (p_user_id, v_streak_bonus, 'streak_bonus', 'streak');
  END IF;

  UPDATE public.user_profiles SET
    total_stars = total_stars + v_stars_to_award + v_streak_bonus,
    current_streak = v_new_streak,
    longest_streak = GREATEST(longest_streak, v_new_streak),
    last_login_date = CURRENT_DATE
  WHERE id = p_user_id;

  RETURN jsonb_build_object(
    'already_logged', false,
    'stars_awarded', v_stars_to_award,
    'streak_bonus', v_streak_bonus,
    'current_streak', v_new_streak,
    'total_stars', (SELECT total_stars FROM public.user_profiles WHERE id = p_user_id)
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.award_dream_stars(p_user_id UUID, p_dream_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.star_transactions (user_id, amount, reason, reference_type, reference_id)
  VALUES (p_user_id, 2, 'add_dream', 'dream', p_dream_id);
  UPDATE public.user_profiles SET total_stars = total_stars + 2 WHERE id = p_user_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.award_completion_stars(p_user_id UUID, p_dream_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.star_transactions (user_id, amount, reason, reference_type, reference_id)
  VALUES (p_user_id, 3, 'complete_goal', 'dream', p_dream_id);
  UPDATE public.user_profiles SET total_stars = total_stars + 3 WHERE id = p_user_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.award_reflection_stars(p_user_id UUID, p_reflection_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.star_transactions (user_id, amount, reason, reference_type, reference_id)
  VALUES (p_user_id, 1, 'reflection', 'reflection', p_reflection_id);
  UPDATE public.user_profiles SET total_stars = total_stars + 1 WHERE id = p_user_id;
END;
$$;

-- ============================================================
-- 8. Storage bucket for profile photos
-- ============================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-photos', 'profile-photos', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "users_upload_own_photos" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'profile-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "users_update_own_photos" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'profile-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "users_delete_own_photos" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'profile-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "public_read_photos" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'profile-photos');
