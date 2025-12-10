<script setup>
import { ref, defineEmits } from 'vue';
import axios from 'axios';

const emit = defineEmits(['login-success']);

const username = ref('');
const password = ref('');
const message = ref('');
const messageType = ref('');

const handleSubmit = async () => {
    message.value = '';
    messageType.value = '';

    try {
        const response = await axios.post('http://localhost:3000/api/login', {
            username: username.value,
            password: password.value
        });

        if (response.data.ok) {
            emit('login-success', response.data.role);
        }
    } catch (err) {
        const errorDetail = err.response?.data?.error || 'Network error.';
        message.value = `Login failed: ${errorDetail}`;
        messageType.value = 'error';
    }
};
</script>

<template>
    <div class="login-container">
        <h3>Login to Access Protected Views</h3>
        <form @submit.prevent="handleSubmit" class="login-form">
            <div class="form-group">
                <label for="username">Username:</label>
                <input type="text" id="username" v-model="username" required>
            </div>
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" v-model="password" required>
            </div>
            <button type="submit" class="submit-button">Login</button>
        </form>

        <div v-if="message" :class="['message-box', messageType]">
            {{ message }}
        </div>

        <div class="credentials">
            <p>Admin Test Credentials: <strong>admin / admin123</strong></p>
            <p>Secretary Test Credentials: <strong>secretary / secret123</strong></p>
        </div>
    </div>
</template>

<style scoped>
.login-container { padding: 40px; max-width: 400px; margin: 50px auto; border: 1px solid #ddd; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
.login-container h3 { text-align: center; margin-bottom: 25px; color: #333; }
.form-group { margin-bottom: 20px; }
.form-group label { display: block; font-weight: bold; margin-bottom: 8px; }
.form-group input { width: 100%; padding: 12px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
.submit-button { background-color: #007bff; color: white; padding: 12px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; width: 100%; }
.submit-button:hover { background-color: #0056b3; }
.message-box { margin-top: 20px; padding: 10px; border-radius: 4px; font-weight: bold; }
.message-box.error { background-color: #f8d7da; color: #721c24; border-color: #f5c6cb; }
.credentials { margin-top: 30px; padding: 15px; border-top: 1px solid #eee; font-size: 0.9em; color: #666; }
</style>