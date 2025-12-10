<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';

const form = ref({
  classID: null,
  deptID: null,
  priority: 1,
  equipRequest: '',
  preferredRoomID: null,
  preferredTime: '',
  cardBltID: null
});

const departments = ref([]);
const rooms = ref([]);

const message = ref('');
const messageType = ref('');

const fetchDropdownData = async () => {
  try {
    const [deptRes, roomRes] = await Promise.all([
      axios.get('http://localhost:3000/api/departments'),
      axios.get('http://localhost:3000/api/rooms')
    ]);
    departments.value = deptRes.data;
    rooms.value = roomRes.data;
  } catch (err) {
    message.value = 'Failed to load dropdown data: ' + err.message;
    messageType.value = 'error';
  }
};

const handleSubmit = async () => {
  message.value = '';
  messageType.value = '';
  
  if (!form.value.classID || !form.value.deptID || !form.value.preferredTime) {
    message.value = 'Class ID, Department, and Preferred Time are mandatory.';
    messageType.value = 'error';
    return;
  }
  
  try {
    const response = await axios.post('http://localhost:3000/api/requests', form.value);
    
    message.value = `Success! Request submitted with ID: ${response.data.requestID}`;
    messageType.value = 'success';
    
    form.value = {
      classID: null,
      deptID: null,
      priority: 1,
      equipRequest: '',
      preferredRoomID: null,
      preferredTime: '',
      cardBltID: null
    };
    
  } catch (err) {
    const errorDetail = err.response?.data?.error || err.message;
    message.value = `Submission failed: ${errorDetail}`;
    messageType.value = 'error';
  }
};

onMounted(fetchDropdownData);
</script>

<template>
  <div class="request-form-container">
    <h3>Department Secretary: Submit New Classroom Request</h3>
    <form @submit.prevent="handleSubmit" class="request-form">
      
      <div class="form-group">
        <label for="classID">Class ID (Required):</label>
        <input type="number" id="classID" v-model="form.classID" required>
      </div>

      <div class="form-group">
        <label for="deptID">Department (Required):</label>
        <select id="deptID" v-model="form.deptID" required>
          <option :value="null" disabled>Select Department</option>
          <option v-for="dept in departments" :key="dept.DeptID" :value="dept.DeptID">
            {{ dept.DeptName }}
          </option>
        </select>
      </div>

      <div class="form-group">
        <label for="preferredTime">Preferred Time/Day (e.g., Mon 10:00-11:00) (Required):</label>
        <input type="text" id="preferredTime" v-model="form.preferredTime" required>
      </div>

      <div class="form-group">
        <label for="priority">Priority (1-5, 5 is highest):</label>
        <input type="number" id="priority" v-model="form.priority" min="1" max="5">
      </div>
      
      <div class="form-group">
        <label for="preferredRoomID">Preferred Room (Optional):</label>
        <select id="preferredRoomID" v-model="form.preferredRoomID">
          <option :value="null">No Preference</option>
          <option v-for="room in rooms" :key="room.RoomID" :value="room.RoomID">
            {{ room.RoomNumber }} ({{ room.BldgName }}, {{ room.Capacity }} cap.)
          </option>
        </select>
      </div>
      
      <div class="form-group">
        <label for="equipRequest">Equipment Request (Optional):</label>
        <input type="text" id="equipRequest" v-model="form.equipRequest">
      </div>
      
      <div class="form-group">
        <label for="cardBltID">Card Blackout ID (Optional):</label>
        <input type="number" id="cardBltID" v-model="form.cardBltID">
      </div>

      <button type="submit" class="submit-button">Submit Request</button>
    </form>

    <div v-if="message" :class="['message-box', messageType]">
      {{ message }}
    </div>
  </div>
</template>

<style scoped>
.request-form-container {
  padding: 20px;
  max-width: 600px;
  margin: 20px auto;
  border: 1px solid #ccc;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
.request-form h3 {
  text-align: center;
  color: #333;
}
.form-group {
  margin-bottom: 15px;
}
.form-group label {
  display: block;
  font-weight: bold;
  margin-bottom: 5px;
}
.form-group input, .form-group select {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  box-sizing: border-box;
}
.submit-button {
  background-color: #007bff;
  color: white;
  padding: 12px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
  width: 100%;
}
.submit-button:hover {
  background-color: #0056b3;
}
.message-box {
  margin-top: 20px;
  padding: 10px;
  border-radius: 4px;
}
.message-box.success {
  background-color: #d4edda;
  color: #155724;
  border-color: #c3e6cb;
}
.message-box.error {
  background-color: #f8d7da;
  color: #721c24;
  border-color: #f5c6cb;
}
</style>