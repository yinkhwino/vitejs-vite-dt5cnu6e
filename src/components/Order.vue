<template>
  <div class="p-4">
    <h1 class="text-2xl font-bold mb-4">{{ title }}</h1>

    <!-- File Upload -->
    <div class="mb-8">
      <h2 class="text-xl mb-4">Import Compressor Sensor Data</h2>
      <div class="flex flex-col gap-4">
        <div>
          <input
            type="file"
            accept=".csv"
            @change="handleFileUpload"
            class="file-input file-input-bordered w-full max-w-xs"
          />
          <p class="text-sm text-gray-600 mt-2">
            Expected CSV format: time, temperature, vibration, strain, pressure, acousticemission, bladehealthscore
          </p>
        </div>

        <div v-if="importError" class="alert alert-error">
          <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
          <span>{{ importError }}</span>
        </div>

        <!-- Data Summary -->
        <div v-if="dataSummary" class="mb-4">
          <div class="stats shadow">
            <div class="stat">
              <div class="stat-title">Average Temperature</div>
              <div class="stat-value">{{ dataSummary.avgTemp.toFixed(1) }}°C</div>
            </div>
            <div class="stat">
              <div class="stat-title">Max Temperature</div>
              <div class="stat-value">{{ dataSummary.maxTemp.toFixed(1) }}°C</div>
            </div>
            <div class="stat">
              <div class="stat-title">Blade Health Score</div>
              <div class="stat-value">{{ dataSummary.avgHealth.toFixed(1) }}</div>
            </div>
          </div>
        </div>

        <!-- Data Table -->
        <div v-if="importedData.length > 0" class="overflow-x-auto">
          <table class="table table-zebra w-full">
            <thead>
              <tr>
                <th>Time (s)</th>
                <th>Temperature (°C)</th>
                <th>Vibration (mm/s)</th>
                <th>Strain (µε)</th>
                <th>Pressure (bar)</th>
                <th>Acoustics (dB)</th>
                <th>Health Score</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, index) in importedData" :key="index">
                <td>{{ row.time }}</td>
                <td>{{ row.temperature.toFixed(1) }}</td>
                <td>{{ row.vibration.toFixed(3) }}</td>
                <td>{{ row.strain.toFixed(1) }}</td>
                <td>{{ row.pressure.toFixed(2) }}</td>
                <td>{{ row.acousticemission.toFixed(2) }}</td>
                <td>
                  <span :class="getHealthScoreClass(row.bladehealthscore)">
                    {{ row.bladehealthscore.toFixed(1) }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Health Analysis -->
    <div v-if="healthAnalysis" class="mb-8">
      <h2 class="text-xl mb-4">Blade Health Analysis</h2>
      <div class="card bg-base-100 shadow-xl">
        <div class="card-body">
          <h3 class="card-title">Status: {{ healthAnalysis.status }}</h3>
          <p>Failure Probability: {{ healthAnalysis.failureProbability }}%</p>
          <p>Estimated Remaining Cycles: {{ healthAnalysis.remainingCycles }}</p>
          <p>Last Analysis: {{ new Date().toLocaleString() }}</p>
          
          <div v-if="healthAnalysis.status === 'Warning'" class="alert alert-warning mt-4">
            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>
            <span>High temperature detected. Consider scheduling maintenance.</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Export Section -->
    <div class="mb-4">
      <h2 class="text-xl mb-4">Export Analysis</h2>
      <button
        @click="exportToCSV"
        class="btn btn-primary"
        :disabled="!hasDataToExport"
      >
        Export to CSV
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import Papa from 'papaparse';
import { supabase } from '../lib/supabaseClient';

const router = useRouter();
const title = 'Blade Health Analysis';
const importedData = ref([]);
const importError = ref('');
const hasDataToExport = computed(() => importedData.value.length > 0);

// Add auth state handling
const authListener = supabase.auth.onAuthStateChange((event, session) => {
  if (event === 'SIGNED_OUT') {
    router.push('/');
  }
});

// Cleanup listener on component unmount
onUnmounted(() => {
  if (authListener) {
    authListener.data.subscription.unsubscribe();
  }
});

// this actually extra extra codes, you actually know what you doing ;)
const validateRow = (row) => {
  const requiredFields = ['time', 'temperature', 'vibration', 'strain', 'pressure', 'acousticemission', 'bladehealthscore'];
  const missingFields = requiredFields.filter(field => !(field in row));
  
  if (missingFields.length > 0) {
    throw new Error(`Missing required fields: ${missingFields.join(', ')}`);
  }

  const numericFields = {
    time: parseInt(row.time),
    temperature: parseFloat(row.temperature),
    vibration: parseFloat(row.vibration),
    strain: parseFloat(row.strain),
    pressure: parseFloat(row.pressure),
    acousticemission: parseFloat(row.acousticemission),
    bladehealthscore: parseFloat(row.bladehealthscore)
  };

  for (const [field, value] of Object.entries(numericFields)) {
    if (isNaN(value)) {
      throw new Error(`Invalid numeric value for ${field}: ${row[field]}`);
    }
  }

  return numericFields;
};

const dataSummary = computed(() => {
  if (!importedData.value.length) return null;
  
  const temps = importedData.value.map(row => row.temperature);
  const healthScores = importedData.value.map(row => row.bladehealthscore);
  
  return {
    avgTemp: temps.reduce((a, b) => a + b) / temps.length,
    maxTemp: Math.max(...temps),
    avgHealth: healthScores.reduce((a, b) => a + b) / healthScores.length
  };
});

const healthAnalysis = computed(() => {
  if (!dataSummary.value) return null;

  const avgHealth = dataSummary.value.avgHealth;
  const maxTemp = dataSummary.value.maxTemp;
  
  let status = 'Normal';
  let failureProbability = 0;
  let remainingCycles = 'Unknown';

//this is random value, adjust as you need for your project ;)
  if (avgHealth < 51 || maxTemp > 555) {
    status = 'Warning';
    failureProbability = ((55 - avgHealth) * 2).toFixed(1);
    remainingCycles = Math.floor((avgHealth - 45) * 100);
  } else {
    failureProbability = ((52 - avgHealth) * 0.5).toFixed(1);
    remainingCycles = Math.floor((avgHealth - 48) * 200);
  }

  return {
    status,
    failureProbability,
    remainingCycles
  };
});

const getHealthScoreClass = (score) => {
  if (score < 50) return 'text-error font-bold';
  if (score < 52) return 'text-warning font-bold';
  return 'text-success font-bold';
};

const handleFileUpload = (event) => {
  const file = event.target.files[0];
  importError.value = '';
  importedData.value = [];
  
  if (!file) return;

  if (file.type !== 'text/csv' && !file.name.endsWith('.csv')) {
    importError.value = 'Please upload a CSV file';
    return;
  }

  const reader = new FileReader();
  reader.onload = (e) => {
    const csv = e.target.result;
    Papa.parse(csv, {
      header: true,
      skipEmptyLines: 'greedy',
      trimHeaders: true,
      transform: (value) => value.trim(),
      dynamicTyping: true,
      complete: (results) => {
        try {
          if (results.errors.length > 0) {
            const errorMessages = results.errors.map(err => 
              `Row ${err.row + 1}: ${err.message}`
            ).join('; ');
            throw new Error(errorMessages);
          }

          if (results.data.length === 0) {
            throw new Error('CSV file is empty');
          }

          // Check if headers are correct
          const expectedHeaders = ['time', 'temperature', 'vibration', 'strain', 'pressure', 'acousticemission', 'bladehealthscore'];
          const headers = Object.keys(results.data[0]);
          const missingHeaders = expectedHeaders.filter(h => !headers.includes(h));
          
          if (missingHeaders.length > 0) {
            throw new Error(`Missing required columns: ${missingHeaders.join(', ')}`);
          }

          importedData.value = results.data.map((row, index) => {
            try {
              return validateRow(row);
            } catch (err) {
              throw new Error(`Error in row ${index + 1}: ${err.message}`);
            }
          });
        } catch (err) {
          importError.value = `Error parsing CSV: ${err.message}`;
          importedData.value = [];
        }
      },
      error: (error) => {
        importError.value = 'Error reading file: ' + error.message;
        importedData.value = [];
      },
    });
  };

  reader.onerror = () => {
    importError.value = 'Error reading file';
    importedData.value = [];
  };

  reader.readAsText(file);
};

const exportToCSV = () => {
  if (!importedData.value.length) return;

  const analysisData = importedData.value.map(row => ({
    ...row,
    analysis_timestamp: new Date().toISOString(),
    health_status: healthAnalysis.value.status,
    failure_probability: healthAnalysis.value.failureProbability,
    remaining_cycles: healthAnalysis.value.remainingCycles
  }));

  const csv = Papa.unparse(analysisData);
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = window.URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.setAttribute('download', `blade_analysis_${new Date().toISOString()}.csv`);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  window.URL.revokeObjectURL(url);
};
</script>

<style scoped>
.stat-value {
  font-size: 1.5rem;
}
</style>