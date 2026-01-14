<template>
    <div>
        <h1 class="signup-container">Signup</h1>
        <form @submit.prevent="Signup">
            <div>
                <label>Nome:</label>
                <input type="text" v-model="name" required />
            </div>
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
        <ul v-if="errors.length" class="error">
            <li v-for="(erro, index) in errors" :key="index">{{ erro }}</li>
        </ul>
    </div>
</template>

<script>
import api from '../services/api'

export default {
    name: 'SignupView',
    data() {
        return {
            name: '',
            email: '',
            password: '',
            errors: []
        };
    },
    methods: {
        async Signup(){
            try {
                const response = await api.post('/signup', {
                    "user": {
                        name: this.name,
                        email: this.email,
                        password: this.password
                    }
                })

                console.log(response)

                this.$router.push('/login');
            } catch (erro) {
                if(erro.response && erro.response.data.errors){
                    this.errors = erro.response.data.errors;
                }else{
                    this.errors = ['Erro inesperado'];
                }
            }
        }
    }
};
</script>

<style>
.signup-container{
    max-width: 300px;
    margin: auto;
    padding: 20px;
}

.error{
   color: red;
}
</style>