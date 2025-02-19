<template>
  <div class="card">
    <div v-if="$slots.header" class="card-header">
      <slot name="header"></slot>
    </div>

    <div v-if="$slots.default" class="card-content"><slot /></div>

    <div v-if="$slots.footer" class="card-footer">
      <slot name="footer"></slot>
    </div>
  </div>
</template>
<style>
.card {
  border: 1px solid #000000;
  padding: 0px;
}
.card-header {
  background-color: #6cb4ee;
  padding: 4px;
}

.card-content {
  padding: 4px;
}
.card-footer {
  background-color: #f5f5f5;
  padding: 4px;
}
</style>
