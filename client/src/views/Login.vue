<template>
    <div>
        <h1>Login</h1>
        <form>
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
    </div>
</template>