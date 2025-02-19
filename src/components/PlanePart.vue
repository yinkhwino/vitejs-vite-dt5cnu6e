<template>
  <div class="p-4">
    <h1 class="text-2xl font-bold mb-4">Plane Parts Dashboard</h1>
    
    <div v-if="loading" class="flex justify-center items-center py-8">
      <span class="loading loading-spinner loading-lg"></span>
    </div>

    <div v-else-if="error" class="alert alert-error">
      <span>{{ error }}</span>
    </div>

    <div v-else>
      <div v-if="components.length" class="overflow-x-auto">
        <table class="table table-zebra w-full">
          <thead>
            <tr>
              <th>Name</th>
              <th>Type</th>
              <th>Stage</th>
              <th>Manufacturer</th>
              <th>Serial Number</th>
              <th>Max Temperature</th>
              <th>Total Cycles</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in components" :key="item.id">
              <td>{{ item.name }}</td>
              <td>{{ item.type }}</td>
              <td>{{ item.stage }}</td>
              <td>{{ item.manufacturer }}</td>
              <td>{{ item.serial_number }}</td>
              <td>{{ item.max_allowable_temperature }}°C</td>
              <td>{{ item.total_cycles }}</td>
              <td>
                <button
                  class="btn btn-primary btn-sm"
                  @click="$router.push('/order')"
                >
                  Order
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-else class="text-center py-8">
        <p class="text-gray-500">No components found.</p>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  components: {
    type: Array,
    default: () => [],
  },
  loading: {
    type: Boolean,
    default: false,
  },
  error: {
    type: String,
    default: null,
  },
});
</script>