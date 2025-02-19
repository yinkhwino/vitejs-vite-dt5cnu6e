/*
  # Add components table and initial data

  1. New Tables
    - `components`
      - `id` (uuid, primary key)
      - `name` (text)
      - `type` (text)
      - `stage` (text)
      - `manufacturer` (text)
      - `serial_number` (text)
      - `cooling_type` (text)
      - `coating_type` (text)
      - `stress_level` (float)
      - `max_allowable_temperature` (float)
      - `total_cycles` (integer)
      - `created_at` (timestamptz)
      - `user_id` (uuid, foreign key)

  2. Security
    - Enable RLS on `components` table
    - Add policies for authenticated users to:
      - Read their own components
      - Insert their own components
      - Update their own components
*/

-- Create the components table
CREATE TABLE IF NOT EXISTS components (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    type text,
    stage text,
    manufacturer text,
    serial_number text,
    cooling_type text,
    coating_type text,
    stress_level float,
    max_allowable_temperature float,
    total_cycles integer,
    created_at timestamptz DEFAULT now(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Enable Row Level Security
ALTER TABLE components ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can read own components"
    ON components
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own components"
    ON components
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own components"
    ON components
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Insert initial data
INSERT INTO components (name, type, stage, manufacturer, serial_number, cooling_type, coating_type, stress_level, max_allowable_temperature, total_cycles)
VALUES
    ('Compressor Blade', 'HP Compressor', 'Stage 1', 'CFM International', 'CFM-1221-5555', 'Film cooled', 'TBCs', 700, 450, 5000),
    ('Compressor Blade', 'HP Compressor', 'Stage 2', 'CFM International', 'CFM-1221-5556', 'Film cooled', 'TBCs', 700, 450, 5000),
    ('Compressor Blade', 'HP Compressor', 'Stage 3', 'CFM International', 'CFM-1221-5557', 'Film cooled', 'TBCs', 700, 450, 5000),
    ('Compressor Blade', 'HP Compressor', 'Stage 4', 'CFM International', 'CFM-1221-5558', 'Film cooled', 'TBCs', 700, 450, 5000),
    ('Compressor Blade', 'HP Compressor', 'Stage 5', 'CFM International', 'CFM-1221-5559', 'Film cooled', 'TBCs', 700, 460, 5000),
    ('Compressor Blade', 'HP Compressor', 'Stage 6', 'CFM International', 'CFM-1221-5560', 'Film cooled', 'TBCs', 700, 470, 5000),
    ('Compressor Blade', 'HP Compressor', 'Stage 7', 'CFM International', 'CFM-1221-5561', 'Film cooled', 'TBCs', 700, 480, 5000),
    ('Compressor Blade', 'HP Compressor', 'Stage 8', 'CFM International', 'CFM-1221-5562', 'Film cooled', 'TBCs', 700, 490, 5000),
    ('Compressor Blade', 'HP Compressor', 'Stage 9', 'CFM International', 'CFM-1221-5563', 'Film cooled', 'TBCs', 700, 495, 5000),
    ('Compressor Blade', 'HP Compressor', 'Stage 10', 'CFM International', 'CFM-1221-5564', 'Film cooled', 'TBCs', 700, 500, 5000),
    ('Compressor Blade', 'LP Compressor', 'Stage 1', 'CFM International', 'CFM-1222-5555', 'Film cooled', 'nickel-based super alloys', 1, 350, 10000),
    ('Compressor Blade', 'LP Compressor', 'Stage 2', 'CFM International', 'CFM-1222-5556', 'Film cooled', 'nickel-based super alloys', 1, 400, 10000),
    ('Compressor Blade', 'LP Compressor', 'Stage 3', 'CFM International', 'CFM-1222-5557', 'Film cooled', 'nickel-based super alloys', 1, 450, 10000),
    ('Turbine Blade', 'HP Turbine', 'Stage 1', 'GE', 'GE-000-0001', 'Film cooled', 'TBCs', 800, 1200, 3000),
    ('Turbine Blade', 'HP Turbine', 'Stage 2', 'GE', 'GE-000-0002', 'Film cooled', 'TBCs', 800, 1230, 3000),
    ('Turbine Blade', 'HP Turbine', 'Stage 3', 'GE', 'GE-000-0003', 'Film cooled', 'TBCs', 800, 1250, 3000),
    ('Turbine Blade', 'HP Turbine', 'Stage 4', 'GE', 'GE-000-0004', 'Film cooled', 'TBCs', 800, 1280, 3000),
    ('Turbine Blade', 'HP Turbine', 'Stage 5', 'GE', 'GE-000-0005', 'Film cooled', 'TBCs', 800, 1300, 3000),
    ('Turbine Blade', 'HP Turbine', 'Stage 6', 'GE', 'GE-000-0006', 'Film cooled', 'TBCs', 800, 1400, 3000),
    ('Turbine Blade', 'HP Turbine', 'Stage 7', 'GE', 'GE-000-0007', 'Film cooled', 'TBCs', 800, 1500, 3000),
    ('Turbine Blade', 'LP Turbine', 'Stage 1', 'GE', 'GE-000-0008', 'Film cooled', 'TBCs', 800, 700, 3000),
    ('Turbine Blade', 'LP Turbine', 'Stage 2', 'GE', 'GE-000-0009', 'Film cooled', 'TBCs', 800, 950, 3000),
    ('Combustion Chamber Pressure', 'Combustion Chamber', null, 'CFM International', 'CFM-1300-5501', 'Airflow', 'TBCs/CMC', 1500, 35, 10000),
    ('Turbine Inlet Temperature (TIT)', 'Combustion Chamber -> Turbine', null, 'CFM International', 'CFM-1300-5502', 'Erosion resistant', 'Metallic', 1700, 1550, 25000),
    ('Fuel-Air Ratio', 'Combustion', 'Overall', 'Leap', 'LEAP-0231-00001', 'Corosion-resist', 'Anti-coking', 0.5, 0.03, 20000),
    ('NOx Emissions', 'Combustion (Efficient Combustion)', '50% reduction vs older engines', 'Leap', 'LEAP-0231-00002', 'TAPs', '-', null, null, 20000),
    ('CO Emissions', 'Combustion (Efficient Combustion)', 'Minimized', 'Leap', 'LEAP-0231-00003', 'Airflow', 'Catalytic', 1700, 1300, 20000),
    ('Combustion Efficiency', 'Combustion Chamber', null, 'CFM International', 'CFM-1300-5503', 'Airflow', 'TBCs', null, 1700, 99),
    ('Exhaust Gas Temperature', 'EGT', 'Exhaust', 'Leap', 'LEAP-0231-00004', 'Airflow', 'TBCs', 1050, 1500, null);