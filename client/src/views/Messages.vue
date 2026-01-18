<template>
  <div class="messages-page">
    <aside class="sidebar">
      <header class="sidebar-header">
        <h2>Mensagens</h2>
      </header>

      <button @click="showNewChatModal = true" class="new-chat-btn">
        + Nova Conversa
      </button>

      <div class="conversations-list">
        <div 
          v-for="conversation in conversations" 
          :key="conversation.userId"
          @click="selectConversation(conversation)"
          :class="['conversation-item', { active: selectedUser && selectedUser.id === conversation.userId }]"
        >
          <div class="user-avatar">
            {{ conversation.userName.charAt(0).toUpperCase() }}
          </div>
          <div class="conversation-info">
            <div class="conversation-header">
              <div class="user-name">{{ conversation.userName }}</div>
              <div class="last-time">{{ formatShortTime(conversation.lastTime) }}</div>
            </div>
            <div class="last-message">{{ conversation.lastMessage }}</div>
          </div>
        </div>

        <div v-if="conversations.length === 0" class="empty-state">
          <p>Nenhuma conversa ainda</p>
          <p class="empty-subtitle">Clique em "Nova Conversa" para começar</p>
        </div>
      </div>

      <div class="sidebar-footer">
        <button @click="logout" class="logout-btn">
          Sair
        </button>
      </div>
    </aside>

    <main class="chat-area">
      <template v-if="selectedUser">
        <header class="chat-header">
          <div class="user-info">
            <div class="user-avatar">
              {{ selectedUser.name.charAt(0).toUpperCase() }}
            </div>
            <div>
              <h3>{{ selectedUser.name }}</h3>
            </div>
          </div>
        </header>

        <div class="messages-container" ref="messagesContainer" @scroll="handleScroll">
          <div v-if="isLoading" class="loading-indicator">Carregando...</div>
          <div 
            v-for="message in currentMessages" 
            :key="message.id"
            :class="['message', message.sender_id === currentUserId ? 'sent' : 'received']"
          >
            <div class="message-bubble">
              <div class="message-content">{{ message.content }}</div>
              <div class="message-time">{{ formatTime(message.created_at) }}</div>
            </div>
          </div>
        </div>

        <footer class="message-input-area">
          <div class="input-wrapper">
            <input 
              v-model="newMessage" 
              @keyup.enter="sendMessage"
              placeholder="Digite uma mensagem"
              class="message-input"
            />
            <button 
              @click="sendMessage" 
              :disabled="!newMessage.trim()" 
              class="send-btn"
              :class="{ 'has-text': newMessage.trim() }"
            >
              <svg viewBox="0 0 24 24" width="24" height="24">
                <path fill="currentColor" d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"></path>
              </svg>
            </button>
          </div>
        </footer>
      </template>

      <div v-else class="empty-chat">
        <div class="empty-chat-content">
          <p>Selecione uma conversa para começar a enviar mensagens</p>
        </div>
      </div>
    </main>

    <div v-if="showNewChatModal" class="modal-overlay" @click="closeModal">
      <div class="modal" @click.stop>
        <div class="modal-header">
          <h3>Nova Conversa</h3>
          <button @click="closeModal" class="modal-close">&times;</button>
        </div>
        <div class="modal-body">
          <input 
            type="text" 
            placeholder="Pesquisar contato..." 
            class="search-input"
            v-model="searchQuery"
          />
          <div class="users-list">
            <div 
              v-for="user in filteredUsers" 
              :key="user.id"
              @click="startNewChatWithUser(user.id)"
              class="user-item"
            >
              <div class="user-avatar small">
                {{ user.name.charAt(0).toUpperCase() }}
              </div>
              <div class="user-details">
                <div class="user-name">{{ user.name }}</div>
                <div class="user-email">{{ user.email }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from '../services/api';
import { createConsumer } from '@rails/actioncable';
import { formatTime, formatShortTime } from '../utils/dateUtils';

export default {
  name: 'MessagesView',
  data() {
    return {
      messages: [], 
      activeMessages: [],
      page: 1,
      hasMore: true,
      isLoading: false,
      conversations: [],
      allUsers: [],
      usersMap: new Map(),
      selectedUser: null,
      newMessage: '',
      currentUserId: null,
      showNewChatModal: false,
      selectedNewUserId: '',
      searchQuery: '',
      cable: null,
      subscription: null
    };
  },
  computed: {
    currentMessages() {
      return this.activeMessages;
    },
    filteredUsers() {
      if (!this.searchQuery) return this.allUsers;
      const query = this.searchQuery.toLowerCase();
      return this.allUsers.filter(user => 
        user.name.toLowerCase().includes(query) || 
        user.email.toLowerCase().includes(query)
      );
    }
  },
  watch: {
    '$route.params.id': {
      handler(newId) {
        if (newId) {
          this.selectUserById(newId);
        } else {
          this.selectedUser = null;
        }
      }
    }
  },
  async mounted() {
    await this.loadData();
    this.setupActionCable();
    
    if (this.$route.params.id) {
      this.selectUserById(this.$route.params.id);
    }
  },
  beforeDestroy() {
    this.subscription?.unsubscribe();
    this.cable?.disconnect();
  },
  methods: {
    formatTime,
    formatShortTime,

    async loadData() {
      const token = localStorage.getItem('token');
      if (!token) return this.$router.push('/login');

      try {
        const payload = JSON.parse(atob(token.split('.')[1]));
        this.currentUserId = payload.user_id;
        api.defaults.headers.common['Authorization'] = `Bearer ${token}`;

        const [usersRes, messagesRes] = await Promise.all([
          api.get('/users'),
          api.get('/messages')
        ]);

        this.allUsers = usersRes.data.filter(u => u.id !== this.currentUserId);
        this.usersMap = new Map(usersRes.data.map(user => [user.id, user]));

        this.messages = messagesRes.data;
        this.buildConversations();
      } catch (error) {
        if (error.response?.status === 401) {
          localStorage.removeItem('token');
          this.$router.push('/login');
        }
      }
    },

    async fetchMessages(userId, reset = false) {
      if (this.isLoading || (!this.hasMore && !reset)) return;
      
      this.isLoading = true;
      if (reset) {
        this.page = 1;
        this.activeMessages = [];
        this.hasMore = true;
      }

      try {
        const response = await api.get(`/messages/${userId}`, {
          params: { page: this.page }
        });

        const newMessages = response.data;
        
        if (newMessages.length < 20) {
          this.hasMore = false;
        }

        if (reset) {
          this.activeMessages = newMessages;
          this.scrollToBottom();
        } else {
          const container = this.$refs.messagesContainer;
          const oldHeight = container ? container.scrollHeight : 0;
          const oldScrollTop = container ? container.scrollTop : 0;

          this.activeMessages = [...newMessages, ...this.activeMessages];
          
          this.$nextTick(() => {
            if (container) {
              const newHeight = container.scrollHeight;
              container.scrollTop = newHeight - oldHeight + oldScrollTop;
            }
          });
        }

        this.page++;
      } catch (error) {
        console.error('Error fetching messages:', error);
      } finally {
        this.isLoading = false;
      }
    },

    handleScroll() {
      const container = this.$refs.messagesContainer;
      if (!container) return;

      if (container.scrollTop === 0 && this.hasMore && !this.isLoading) {
        this.fetchMessages(this.selectedUser.id);
      }
    },

    buildConversations() {
      const convMap = new Map();

      this.messages.forEach(msg => {
        const isSender = msg.sender_id === this.currentUserId;
        const otherUserId = isSender ? msg.receiver_id : msg.sender_id;
        const otherUser = this.usersMap.get(otherUserId);
        
        const conversationData = {
          userId: otherUserId,
          userName: otherUser?.name || 'Usuário Desconhecido',
          lastMessage: this.truncateMessage(msg.content),
          lastTime: msg.created_at
        };

        if (!convMap.has(otherUserId)) {
          convMap.set(otherUserId, conversationData);
        } else {
          const existing = convMap.get(otherUserId);
          if (new Date(msg.created_at) > new Date(existing.lastTime)) {
            Object.assign(existing, conversationData);
          }
        }
      });

      this.conversations = Array.from(convMap.values())
        .sort((a, b) => new Date(b.lastTime) - new Date(a.lastTime));
    },

    truncateMessage(content) {
      return content.length > 30 ? content.substring(0, 30) + '...' : content;
    },

    selectConversation(conversation) {
      if (this.$route.params.id !== conversation.userId.toString()) {
        this.$router.push(`/messages/${conversation.userId}`);
      }
    },

    selectUserById(userId) {
      const id = parseInt(userId);
      const user = this.usersMap.get(id) || this.allUsers.find(u => u.id === id) || { id, name: 'Usuário' };
      this.selectedUser = user;
      this.fetchMessages(id, true);
    },

    async sendMessage() {
      if (!this.newMessage.trim() || !this.selectedUser) return;

      try {
        await api.post('/messages', {
          message: {
            receiver_id: this.selectedUser.id,
            content: this.newMessage
          }
        });
        
        this.newMessage = '';
      } catch (error) {
        alert('Erro ao enviar mensagem');
      }
    },

    setupActionCable() {
      const token = localStorage.getItem('token');
      this.cable = createConsumer(`ws://localhost:3000/cable?token=${token}`);
      
      this.subscription = this.cable.subscriptions.create(
        { channel: 'MessagesChannel', user_id: this.currentUserId },
        {
          received: (data) => {
            if (!this.messages.some(m => m.id === data.id)) {
              this.messages.push(data);
              this.buildConversations();
            }
            
            const isRelatedToSelected = this.selectedUser && 
              (data.sender_id === this.selectedUser.id || data.receiver_id === this.selectedUser.id);
              
            if (isRelatedToSelected) {
              if (!this.activeMessages.some(m => m.id === data.id)) {
                this.activeMessages.push(data);
                this.scrollToBottom();
              }
            }
          }
        }
      );
    },

    startNewChatWithUser(userId) {
      this.$router.push(`/messages/${userId}`);
      this.closeModal();
    },

    closeModal() {
      this.showNewChatModal = false;
      this.selectedNewUserId = '';
      this.searchQuery = '';
    },

    scrollToBottom() {
      this.$nextTick(() => {
        const container = this.$refs.messagesContainer;
        if (container) {
          container.scrollTop = container.scrollHeight;
        }
      });
    },

    logout() {
      this.subscription?.unsubscribe();
      this.cable?.disconnect();
      localStorage.removeItem('token');
      this.$router.push('/login');
    }
  }
};
</script>

<style scoped src="../assets/css/messages.css"></style>
