<script setup>
import { ref, onMounted, computed } from 'vue';
import axios from 'axios';

const pendingRequests = ref([]);
const rooms = ref([]);
const selectedRequestId = ref(null);
const selectedRoomId = ref(null);

const assignmentForm = ref({
  dayOfWeek: 'Mon',
  startTime: '08:00',
  endTime: '09:00'
});

const message = ref('');
const messageType = ref('');

const selectedRequest = computed(() => {
  return pendingRequests.value.find(req => req.RequestID === selectedRequestId.value);
});

const fetchAdminData = async () => {
  try {
    const [reqRes, roomRes] = await Promise.all([
      axios.get('http://localhost:3000/api/requests'),
      axios.get('http://localhost:3000/api/rooms')
    ]);
    pendingRequests.value = reqRes.data;
    rooms.value = roomRes.data;
    if (pendingRequests.value.length > 0) {
      selectedRequestId.value = pendingRequests.value[0].RequestID;
    }
  } catch (err) {
    message.value = 'Failed to load data for Admin: ' + err.message;
    messageType.value = 'error';
  }
};

const handleAssign = async () => {
  message.value = '';
  messageType.value = '';

  if (!selectedRequestId.value || !selectedRoomId.value) {
    message.value = 'Please select a Request and a Room.';
    messageType.value = 'error';
    return;
  }

  const payload = {
    requestID: selectedRequestId.value,
    roomID: selectedRoomId.value,
    dayOfWeek: assignmentForm.value.dayOfWeek,
    startTime: assignmentForm.value.startTime,
    endTime: assignmentForm.value.endTime
  };

  try {
    const response = await axios.post('http://localhost:3000/api/assignments', payload);
    message.value = `Success! Assignment created. Refreshing requests...`;
    messageType.value = 'success';
    await fetchAdminData();
    selectedRequestId.value = pendingRequests.value.length > 0 ? pendingRequests.value[0].RequestID : null;
  } catch (err) {
    const errorDetail = err.response?.data?.error || err.message;
    message.value = `Assignment failed: ${errorDetail}`;
    messageType.value = 'error';
  }
};

onMounted(fetchAdminData);
</script>

<template>
  <div class="admin-assignment-container">
    <h3>Administrator: Assign Room to Pending Request</h3>

    <div v-if="message" :class="['message-box', messageType]">
      {{ message }}
    </div>

    <div v-if="pendingRequests.length === 0" class="no-requests">
      All requests have been assigned.
    </div>

    <div v-else class="assignment-panel">
      <div class="requests-list">
        <h4>Pending Requests (Priority)</h4>
        <div 
          v-for="req in pendingRequests" 
          :key="req.RequestID" 
          :class="['request-item', { selected: selectedRequestId === req.RequestID }]"
          @click="selectedRequestId = req.RequestID"
        >
          <span class="priority">P: {{ req.Priority }}</span> 
          <span>{{ req.DeptName }} - {{ req.ClassName }} (S{{ req.SectionNum }})</span>
          <span class="time">{{ req.PreferredTime }}</span>
        </div>
      </div>

      <form @submit.prevent="handleAssign" class="assignment-form">
        <h4>Assignment Details</h4>
        <div v-if="selectedRequest" class="request-summary">
          **Request Details:** {{ selectedRequest.ClassName }} (S{{ selectedRequest.SectionNum }}) - {{ selectedRequest.PreferredTime }}
          <div v-if="selectedRequest.EquipRequest">Equipment Needed: {{ selectedRequest.EquipRequest }}</div>
        </div>
        
        <div class="form-group">
          <label for="room">Select Room:</label>
          <select id="room" v-model="selectedRoomId" required>
            <option :value="null" disabled>-- Select Available Room --</option>
            <option v-for="room in rooms" :key="room.RoomID" :value="room.RoomID">
              {{ room.RoomNumber }} ({{ room.BldgName }}, Cap: {{ room.Capacity }})
            </option>
          </select>
        </div>
        
        <div class="form-group time-inputs">
            <label>Day/Time Slot:</label>
            <select v-model="assignmentForm.dayOfWeek" required>
                <option>Mon</option><option>Tue</option><option>Wed</option><option>Thu</option><option>Fri</option>
            </select>
            <input type="time" v-model="assignmentForm.startTime" required>
            <input type="time" v-model="assignmentForm.endTime" required>
        </div>

        <button type="submit" class="submit-button">Assign Room</button>
      </form>
    </div>
  </div>
</template>

<style scoped>
.admin-assignment-container { 
  padding: 20px; 
  max-width: 1000px; 
  margin: auto; 
  background-color: #1a1a1a;
  color: #f0f0f0;
  min-height: 100vh;
}
.admin-assignment-container h3, .admin-assignment-container h4 {
    color: #ffffff;
}
.assignment-panel { 
  display: flex; 
  gap: 30px; 
  margin-top: 20px; 
}
.requests-list { 
  flex: 1; 
  border: 1px solid #444; 
  padding: 15px; 
  border-radius: 5px; 
  max-height: 500px; 
  overflow-y: auto; 
  background-color: #2c2c2c;
}
.assignment-form { 
  flex: 2; 
  padding: 15px; 
  border: 1px solid #0056b3; 
  border-radius: 5px; 
  background-color: #2c2c2c;
}
.request-item { 
  padding: 10px; 
  margin-bottom: 5px; 
  border: 1px solid #444; 
  border-radius: 4px; 
  cursor: pointer; 
  display: flex; 
  justify-content: space-between; 
  align-items: center;
  background-color: #383838;
  color: #fff;
}
.request-item:hover { 
  background-color: #4a4a4a; 
}
.request-item.selected { 
  background-color: #0056b3; 
  border-color: #007bff; 
  font-weight: bold; 
}
.priority { 
  background-color: #ffc107; 
  padding: 2px 6px; 
  border-radius: 3px; 
  font-size: 0.8em; 
  margin-right: 10px;
  color: #000;
}
.time { 
  font-style: italic; 
  font-size: 0.9em; 
  color: #ccc;
}
.request-summary { 
  padding: 10px; 
  margin-bottom: 15px; 
  background-color: #383838; 
  border: 1px solid #444; 
  border-radius: 4px;
  color: #fff;
}
.form-group { 
  margin-bottom: 15px; 
}
.form-group label {
    display: block;
    margin-bottom: 5px;
    color: #ccc;
}
.form-group select, .form-group input {
    padding: 8px;
    border-radius: 4px;
    border: 1px solid #555;
    background-color: #444;
    color: #fff;
}
.time-inputs select, .time-inputs input { 
  width: 32%; 
  display: inline-block; 
}
.message-box { 
  padding: 10px; 
  margin-bottom: 15px; 
  border-radius: 4px; 
  font-weight: bold; 
}
.message-box.success { 
  background-color: #1f6430; 
  color: #d4edda;
  border-color: #2c7743;
}
.message-box.error { 
  background-color: #8c1e28; 
  color: #f8d7da;
  border-color: #a72d38;
}
.submit-button { 
  background-color: #007bff; 
  color: white; 
  padding: 10px 15px; 
  border: none; 
  border-radius: 4px; 
  cursor: pointer; 
}
</style>