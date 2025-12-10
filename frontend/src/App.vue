<script setup>
import { ref, computed } from 'vue';
import Login from './components/Login.vue';
import AssignmentSchedule from './components/AssignmentSchedule.vue';
import SecretaryRequestForm from './components/SecretaryRequestForm.vue';
import AdminAssignment from './components/AdminAssignment.vue';
import AdminBlackout from './components/AdminBlackout.vue';

const userRole = ref(null);
const activeView = ref('student');

const handleLoginSuccess = (role) => {
    userRole.value = role;
    if (role === 'secretary') {
        activeView.value = 'secretary';
    } else if (role === 'admin') {
        activeView.value = 'admin_assign';
    }
};

const logout = () => {
    userRole.value = null;
    activeView.value = 'student';
};

const isProtectedView = computed(() => {
    return ['secretary', 'admin_assign', 'admin_blackout'].includes(activeView.value);
});

const isAdminView = computed(() => {
    return ['admin_assign', 'admin_blackout'].includes(activeView.value);
});
</script>

<template>
    <header>
        <h1>Classroom Management System</h1>
        <nav>
            <button @click="activeView = 'student'" :class="{ active: activeView === 'student' }">Student View (Schedule)</button>

            <button v-if="!userRole" @click="activeView = 'login'" :class="{ active: activeView === 'login' }">Login</button>
            <button v-else @click="logout" class="logout-button">Logout ({{ userRole }})</button>

            <template v-if="userRole === 'secretary'">
                <button @click="activeView = 'secretary'" :class="{ active: activeView === 'secretary' }">Secretary: Request Form</button>
            </template>
            
            <template v-if="userRole === 'admin'">
                <button @click="activeView = 'admin_assign'" :class="{ active: activeView === 'admin_assign' }">Admin: Assignment</button>
                <button @click="activeView = 'admin_blackout'" :class="{ active: activeView === 'admin_blackout' }">Admin: Blackouts</button>
            </template>
        </nav>
    </header>

    <main>
        <AssignmentSchedule v-if="activeView === 'student'" />

        <Login v-else-if="activeView === 'login'" @login-success="handleLoginSuccess" />

        <div v-else-if="isProtectedView && !userRole" class="access-denied-message">
            <p>Access Denied. Please log in to view this page.</p>
        </div>

        <template v-else>
            <SecretaryRequestForm v-if="activeView === 'secretary' && userRole === 'secretary'" />

            <AdminAssignment v-else-if="activeView === 'admin_assign' && userRole === 'admin'" />
            <AdminBlackout v-else-if="activeView === 'admin_blackout' && userRole === 'admin'" />

            <div v-else-if="isAdminView && userRole === 'secretary'" class="access-denied-message">
                <p>Only Administrators can access this page.</p>
            </div>
        </template>
    </main>
</template>

<style scoped>
header { text-align: center; padding: 20px; border-bottom: 1px solid #eee; }
h1 { margin-bottom: 10px; }
nav button { padding: 10px 15px; margin: 0 5px; border: 1px solid #007bff; background-color: white; color: #007bff; cursor: pointer; border-radius: 5px; font-weight: bold; }
nav button.active { background-color: #007bff; color: white; }
.logout-button { background-color: #dc3545; color: white; border-color: #dc3545; }
.access-denied-message { text-align: center; padding: 40px; color: #dc3545; font-size: 1.2em; border: 1px solid #dc3545; background-color: #f8d7da; max-width: 600px; margin: 50px auto; border-radius: 5px; }
main { padding: 20px 0; }
</style>