import { createClient } from '@supabase/supabase-js'

// This is the project's publishable key, intended for browser applications.
// RLS protects all exposed tables. Never replace this with a service_role key.
const url = import.meta.env.VITE_SUPABASE_URL || 'https://zvozkqdthvyrnesmbwjo.supabase.co'
const publishableKey = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY || 'sb_publishable_88U21aKwsGa02qur7U5zgA_FIzg2jC6'

export const isSupabaseConfigured = Boolean(url && publishableKey)
export const supabase = createClient(url, publishableKey, {
  auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true },
})