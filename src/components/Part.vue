<script setup>
import { ref } from 'vue';
import { supabase } from '../lib/supabaseClient';

const props = defineProps({
  inventory: {
    type: Array,
    default: () => [],
  },
});

const loading = ref(false);
const error = ref(null);
const inspections = ref({});

const inspect = async (itemId, cycles) => {
  if (loading.value) return;
  loading.value = true;
  
  try {
    if (cycles > 1.75) {
      inspections.value[itemId] = true;
    } else {
      inspections.value[itemId] = false;
    }
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};
</script>

<template>
  <div class="inventory-container">
    <div v-if="error" class="error-banner">
      <p>{{ error }}</p>
      <button @click="$emit('retry')" class="retry-button">Retry</button>
    </div>

    <div v-if="loading" class="loading">Loading inventory...</div>

    <div v-else>
      <div v-if="inventory.length" class="overflow-auto">
        <table class="table table-zebra">
          <thead>
            <tr>
              <th>Name</th>
              <th>Lead Time</th>
              <th>Cycles</th>
              <th>Status</th>
              <th>Key Metrics</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in inventory" :key="item.id" @mounted="inspect(item.id, item.cycles)">
              <td>{{ item.name }}</td>
              <td>{{ item.lead_times }}</td>
              <td>{{ item.cycles }}</td>
              <td class="badge">{{ item.status }}</td>
              <td class="inspect">
                <div v-if="inspections[item.id]" class="badge badge-error gap-2">overheated</div>
                <div v-else><div class="badge badge-success">success</div></div>
              </td>
              <td v-if="inspections[item.id]">
                <button class="btn btn-primary" @click="$router.push('/order')">Order</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <p v-else>No inventory items found.</p>
    </div>
  </div>
</template>

<style scoped>
.inventory-container {
  width: 100%;
  position: relative;
}

.error-banner {
  background-color: #fee2e2;
  border: 1px solid #dc2626;
  color: #dc2626;
  padding: 1rem;
  margin-bottom: 1rem;
  border-radius: 4px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.retry-button {
  background-color: #dc2626;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
}

.retry-button:hover {
  background-color: #b91c1c;
}

.loading {
  text-align: center;
  padding: 2rem;
  color: #6b7280;
}
</style>