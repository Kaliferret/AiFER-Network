-- Add theme preference columns to device_settings table
ALTER TABLE public.device_settings 
ADD COLUMN IF NOT EXISTS theme_mode text DEFAULT 'system' CHECK (theme_mode IN ('light', 'dark', 'system')),
ADD COLUMN IF NOT EXISTS follow_system_theme boolean DEFAULT true;

-- Update existing records to have theme settings
UPDATE public.device_settings 
SET 
  theme_mode = 'system',
  follow_system_theme = true
WHERE theme_mode IS NULL;

-- Add index for theme-related queries
CREATE INDEX IF NOT EXISTS idx_device_settings_theme_mode ON public.device_settings(theme_mode);

-- Add comment for documentation
COMMENT ON COLUMN public.device_settings.theme_mode IS 'User preferred theme mode: light, dark, or system';
COMMENT ON COLUMN public.device_settings.follow_system_theme IS 'Whether to follow system theme preference automatically';