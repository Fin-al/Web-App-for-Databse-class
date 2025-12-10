<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';

const assignments = ref([]);
const loading = ref(true);
const error = ref(null);

const fetchAssignments = async () => {
  try {
    const response = await axios.get('http://localhost:3000/api/assignments');
    assignments.value = response.data;
    loading.value = false;
  } catch (err) {
    error.value = 'Failed to load assignments: ' + err.message;
    loading.value = false;
    console.error(err);
  }
};

onMounted(fetchAssignments);
</script>

<template>
  <div class="schedule-container">
    <h2>University Class Schedule</h2>

    <div v-if="loading" class="message">Loading schedule data...</div>
    <div v-else-if="error" class="message error-message">Error: {{ error }}</div>
    
    <table v-else class="schedule-table">
      <thead>
        <tr>
          <th>Department</th>
          <th>Course Name</th>
          <th>Section</th>
          <th>Building</th>
          <th>Room</th>
          <th>Day</th>
          <th>Time Slot</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in assignments" :key="item.SectionNum + item.RoomNumber">
          <td>{{ item.DeptName }}</td>
          <td>{{ item.ClassName }}</td>
          <td>{{ item.SectionNum }}</td>
          <td>{{ item.BldgName }}</td>
          <td>{{ item.RoomNumber }}</td>
          <td>{{ item.DayOfWeek }}</td>
          <td>{{ item.StartTime }} - {{ item.EndTime }}</td>
        </tr>
      </tbody>
    </table>

    <div v-if="assignments.length === 0 && !loading && !error" class="message">
      No class assignments found in the database.
    </div>
  </div>
</template>

<style scoped>
.schedule-container {
  font-family: Arial, sans-serif;
  padding: 20px;
}
.schedule-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 20px;
}
.schedule-table th, .schedule-table td {
  border: 1px solid #ccc;
  padding: 8px 12px;
  text-align: left;
}
.schedule-table th {
  background-color: black;
  color: white; 
}

.schedule-table td {
  background-color: #eee; 
  color: black;
}

.error-message {
  color: red;
  border: 1px solid red;
  padding: 10px;
  background-color: #ffe0e0;
}
</style>