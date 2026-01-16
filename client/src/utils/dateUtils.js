/**
 * Formats a date string to a time string (HH:MM).
 * @param {string} dateString - The date string to format.
 * @returns {string} The formatted time string.
 */
export const formatTime = (dateString) => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
};

/**
 * Formats a date string to a short representation (Time, "Ontem", Day of week, or Date).
 * @param {string} dateString - The date string to format.
 * @returns {string} The formatted short date string.
 */
export const formatShortTime = (dateString) => {
    if (!dateString) return '';
    const date = new Date(dateString);
    const now = new Date();
    const diff = now - date;
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));

    if (days === 0) {
        return date.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
    } else if (days === 1) {
        return 'Ontem';
    } else if (days < 7) {
        return date.toLocaleDateString('pt-BR', { weekday: 'short' });
    } else {
        return date.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' });
    }
};
