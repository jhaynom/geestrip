-- ============================================
-- GeesTrip RLS Policy Setup for Supabase
-- ============================================
-- Run these SQL commands in your Supabase SQL Editor
-- https://app.supabase.com/project/[YOUR_PROJECT]/sql/new

-- ============================================
-- 1. PROFILES TABLE RLS POLICIES
-- ============================================
-- Enable RLS on profiles table
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Policy: Admins can view all profiles
CREATE POLICY "Admins can view all profiles"
  ON public.profiles
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Policy: Admins can update any profile
CREATE POLICY "Admins can update any profile"
  ON public.profiles
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Policy: Users can insert their own profile (for signup)
CREATE POLICY "Users can insert own profile"
  ON public.profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ============================================
-- 2. BOOKINGS TABLE RLS POLICIES
-- ============================================
-- Enable RLS on bookings table
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own bookings
CREATE POLICY "Users can view own bookings"
  ON public.bookings
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Admins can view all bookings
CREATE POLICY "Admins can view all bookings"
  ON public.bookings
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Policy: Users can insert bookings
CREATE POLICY "Users can insert bookings"
  ON public.bookings
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own bookings
CREATE POLICY "Users can update own bookings"
  ON public.bookings
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Admins can delete bookings
CREATE POLICY "Admins can delete bookings"
  ON public.bookings
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- 3. LIVE_CHAT_REQUESTS TABLE RLS POLICIES
-- ============================================
-- Enable RLS on live_chat_requests table
ALTER TABLE public.live_chat_requests ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own chat requests
CREATE POLICY "Users can view own chat requests"
  ON public.live_chat_requests
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Live agents and admins can view all pending chat requests
CREATE POLICY "Agents can view all pending chats"
  ON public.live_chat_requests
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND (role = 'admin' OR role = 'live_agent')
    )
  );

-- Policy: Users can insert chat requests
CREATE POLICY "Users can insert chat requests"
  ON public.live_chat_requests
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Agents and admins can update chat requests they're assigned to
CREATE POLICY "Agents can update assigned chats"
  ON public.live_chat_requests
  FOR UPDATE
  USING (
    auth.uid() = agent_id OR
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  )
  WITH CHECK (
    auth.uid() = agent_id OR
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- 4. MESSAGES TABLE RLS POLICIES
-- ============================================
-- Enable RLS on messages table
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view messages they sent or received
CREATE POLICY "Users can view own messages"
  ON public.messages
  FOR SELECT
  USING (
    auth.uid() = sender_id OR
    auth.uid() = receiver_id
  );

-- Policy: Users can insert messages
CREATE POLICY "Users can insert messages"
  ON public.messages
  FOR INSERT
  WITH CHECK (auth.uid() = sender_id);

-- Policy: Users can update their own messages
CREATE POLICY "Users can update own messages"
  ON public.messages
  FOR UPDATE
  USING (auth.uid() = sender_id)
  WITH CHECK (auth.uid() = sender_id);

-- ============================================
-- 5. PROPERTIES TABLE RLS POLICIES
-- ============================================
-- Enable RLS on properties table
ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can view active properties
CREATE POLICY "Everyone can view active properties"
  ON public.properties
  FOR SELECT
  USING (status = 'active');

-- Policy: Owners can view their own properties
CREATE POLICY "Owners can view own properties"
  ON public.properties
  FOR SELECT
  USING (auth.uid() = owner_id);

-- Policy: Admins can view all properties
CREATE POLICY "Admins can view all properties"
  ON public.properties
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Policy: Owners can insert properties
CREATE POLICY "Owners can insert properties"
  ON public.properties
  FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

-- Policy: Owners can update their own properties
CREATE POLICY "Owners can update own properties"
  ON public.properties
  FOR UPDATE
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

-- Policy: Admins can update any property
CREATE POLICY "Admins can update any property"
  ON public.properties
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- 6. REVIEWS TABLE RLS POLICIES
-- ============================================
-- Enable RLS on reviews table
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can view reviews
CREATE POLICY "Everyone can view reviews"
  ON public.reviews
  FOR SELECT
  USING (true);

-- Policy: Users can insert reviews
CREATE POLICY "Users can insert reviews"
  ON public.reviews
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own reviews
CREATE POLICY "Users can update own reviews"
  ON public.reviews
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Admins can delete reviews
CREATE POLICY "Admins can delete reviews"
  ON public.reviews
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- 7. PAYMENTS TABLE RLS POLICIES (if exists)
-- ============================================
-- Enable RLS on payments table
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own payments
CREATE POLICY "Users can view own payments"
  ON public.payments
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Admins can view all payments
CREATE POLICY "Admins can view all payments"
  ON public.payments
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Policy: Users can insert payments
CREATE POLICY "Users can insert payments"
  ON public.payments
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these to verify RLS is working

-- Check RLS status on all tables
SELECT 
  tablename,
  rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- Check all policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
