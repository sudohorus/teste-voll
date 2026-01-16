<template>
    <div class="page">
        <div class="card">
            <h1>Login</h1>

            <form @submit.prevent="Login">
                <div class="field">
                    <label>Email</label>
                    <input type="email" v-model="email" required />
                </div>

                <div class="field">
                    <label>Senha</label>
                    <input type="password" v-model="password" required />
                </div>

                <button type="submit">Entrar</button>
            </form>
            <p class="link-text">
                Não tem conta?
                <router-link to="/signup">Criar conta</router-link>
            </p>

            <p v-if="error" class="error-box">
                {{ error }}
            </p>
        </div>
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
        }
    },
    methods: {
        async Login() {
            try {
                const response = await api.post('/login', {
                    email: this.email,
                    password: this.password
                })

                localStorage.setItem('token', response.data.token)
                this.$router.push('/messages')
            } catch (erro) {
                this.error = 'Email ou senha inválidos'
                console.log(erro)
            }
        }
    }
}
</script>

<style>
.page {
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    background: #f5f6fa;
    font-family: Arial, sans-serif;
}

.card {
    background: #fff;
    padding: 24px;
    width: 100%;
    max-width: 350px;
    border-radius: 8px;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
}

.card h1 {
    text-align: center;
    margin-bottom: 20px;
}

.field {
    display: flex;
    flex-direction: column;
    margin-bottom: 15px;
}

.field label {
    font-size: 14px;
    margin-bottom: 5px;
    color: #333;
}

.field input {
    padding: 10px;
    border-radius: 5px;
    border: 1px solid #ccc;
    font-size: 14px;
}

.field input:focus {
    outline: none;
    border-color: #5b8def;
}

button {
    width: 100%;
    padding: 10px;
    background: #5b8def;
    border: none;
    color: white;
    font-size: 15px;
    border-radius: 5px;
    cursor: pointer;
    margin-top: 10px;
}

button:hover {
    background: #4a7bd0;
}

.error-box {
    margin-top: 15px;
    padding: 10px;
    background: #ffe6e6;
    color: #b00020;
    border-radius: 5px;
    font-size: 14px;
    text-align: center;
}

.link-text{
    margin-top: 15px;
    text-align: center;
    font-size: 14px;
}

.link-text a{
    color: #5b8def;
    text-decoration: none;
    font-weight: bold;
    margin-left: 4px;
}

.link-text a:hover{
    text-decoration: underline;
}
</style>
