<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';

const rooms = ref([]);

const blackoutForm = ref({
  roomID: null,
  dayOfWeek: 'Mon',
  startTime: '00:00',
  endTime: '00:00',
  reason: ''
});

const message = ref('');
const messageType = ref('');

const fetchRooms = async () => {
  try {
    const res = await axios.get('http://localhost:3000/api/rooms');
    rooms.value = res.data;
  } catch (err) {
    message.value = 'Failed to load rooms: ' + err.message;
    messageType.value = 'error';
  }
};

const handleBlackout = async () => {
  message.value = '';
  messageType.value = '';

  if (!blackoutForm.value.roomID || !blackoutForm.value.reason) {
    message.value = 'Room and Reason are mandatory.';
    messageType.value = 'error';
    return;
  }

  try {
    await axios.post('http://localhost:3000/api/blackouts', blackoutForm.value);
    
    message.value = `Success! Blackout created for Room ${rooms.value.find(r => r.RoomID === blackoutForm.value.roomID)?.RoomNumber}.`;
    messageType.value = 'success';
    
    blackoutForm.value = {
      roomID: null,
      dayOfWeek: 'Mon',
      startTime: '00:00',
      endTime: '00:00',
      reason: ''
    };
    
  } catch (err) {
    const errorDetail = err.response?.data?.error || err.message;
    message.value = `Blackout submission failed: ${errorDetail}`;
    messageType.value = 'error';
  }
};

onMounted(fetchRooms);
</script>

<template>
  <div class="blackout-form-container">
    <h3>Administrator: Set Blackout Hours</h3>
    <p>Prevents a room from being assigned during a specific day/time slot.</p>

    <div v-if="message" :class="['message-box', messageType]">
      {{ message }}
    </div>
    
    <form @submit.prevent="handleBlackout" class="blackout-form">
      
      <div class="form-group">
        <label for="roomID">Select Room:</label>
        <select id="roomID" v-model="blackoutForm.roomID" required>
          <option :value="null" disabled>Select Room</option>
          <option v-for="room in rooms" :key="room.RoomID" :value="room.RoomID">
            {{ room.RoomNumber }} ({{ room.BldgName }})
          </option>
        </select>
      </div>

      <div class="form-group time-inputs">
        <label>Day/Time Slot:</label>
        <select v-model="blackoutForm.dayOfWeek" required>
            <option>Mon</option><option>Tue</option><option>Wed</option><option>Thu</option><option>Fri</option>
        </select>
        <input type="time" v-model="blackoutForm.startTime" required>
        <input type="time" v-model="blackoutForm.endTime" required>
      </div>
      
      <div class="form-group">
        <label for="reason">Reason (e.g., Maintenance, Event):</label>
        <input type="text" id="reason" v-model="blackoutForm.reason" required>
      </div>

      <button type="submit" class="submit-button">Create Blackout</button>
    </form>
  </div>
</template>

<style scoped>
.blackout-form-container { padding: 20px; max-width: 500px; margin: 20px auto; border: 1px solid #ccc; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
.blackout-form h3 { text-align: center; color: #333; }
.form-group { margin-bottom: 15px; }
.form-group label { display: block; font-weight: bold; margin-bottom: 5px; }
.form-group input, .form-group select { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
.time-inputs select, .time-inputs input { width: 32%; display: inline-block; }
.submit-button { background-color: #28a745; color: white; padding: 12px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; width: 100%; }
.submit-button:hover { background-color: #1e7e34; }
.message-box { margin-top: 20px; padding: 10px; border-radius: 4px; font-weight: bold; }
.message-box.success { background-color: #d4edda; color: #155724; border-color: #c3e6cb; }
.message-box.error { background-color: #f8d7da; color: #721c24; border-color: #f5c6cb; }
</style>