<template>
    <div>
        <h1 class="login-container">Login</h1>
        <form @submit.prevent="Login">
            <div>
                <label>Email:</label>
                <input type="email" v-model="email" required />
            </div>
            <div>
                <label>Senha:</label>
                <input type="password" v-model="password" required />
            </div>
            <button type="submit">Entrar</button>
        </form>
        <p v-if="error" class="error">{{ error }}</p>
    </div>
</template>

<script>
import api from '../services/api'

export default {
    name: 'LoginView',
    data() {
        return {
            email: '',
            password: '',
            error: ''
        };
    },
    methods: {
        async Login(){
            try {
                const response = await api.post('/login', {
                    email: this.email,
                    password: this.password
                });

                localStorage.setItem('token', response.data.token);

                this.$router.push('/chat');
            } catch (erro) {
                this.error = "email ou senha inválidos";
                console.log(erro);
            }
        }
    }
};
</script>

<style>
.login-container{
    max-width: 300px;
    margin: auto;
    padding: 20px;
}

.error{
   color: red;
}
</style>