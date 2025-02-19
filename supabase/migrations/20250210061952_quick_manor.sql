/*
  # Fix inventory table foreign key constraint

  1. Changes
    - Drop the existing foreign key constraint
    - Add new foreign key constraint with proper reference to auth.users table
    - Ensure proper cascade behavior for user deletion

  2. Security
    - Maintains existing RLS policies
    - Keeps user data integrity with proper foreign key relationship
*/

-- First, drop the existing foreign key constraint
ALTER TABLE inventory 
DROP CONSTRAINT IF EXISTS inventory_user_id_fkey;

-- Add the correct foreign key constraint with cascade delete
ALTER TABLE inventory
ADD CONSTRAINT inventory_user_id_fkey 
FOREIGN KEY (user_id) 
REFERENCES auth.users(id)
ON DELETE CASCADE;