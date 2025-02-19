/*
  # Create Inventory Management System

  1. New Tables
    - `inventory`
      - `id` (uuid, primary key)
      - `name` (text, required)
      - `lead_times` (float, required)
      - `cycles` (float, required)
      - `status` (text, defaults to 'active')
      - `created_at` (timestamptz, defaults to now)
      - `user_id` (uuid, foreign key to auth.users)

  2. Security
    - Enable RLS on `inventory` table
    - Add policies for:
      - Reading own inventory items
      - Inserting own inventory items
      - Updating own inventory items
*/

-- Create the inventory table
CREATE TABLE IF NOT EXISTS inventory (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  lead_times float NOT NULL,
  cycles float NOT NULL,
  status text DEFAULT 'active',
  created_at timestamptz DEFAULT now(),
  user_id uuid REFERENCES auth.users(id) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can read own inventory"
  ON inventory
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own inventory"
  ON inventory
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own inventory"
  ON inventory
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);