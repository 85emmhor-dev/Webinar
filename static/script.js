document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('signup-form');
    const nameInput = document.getElementById('name');
    const emailInput = document.getElementById('email');
    const validationMessage = document.getElementById('validation-message');

    // Hämta färger
    const accentColor = getComputedStyle(document.documentElement).getPropertyValue('--accent-gold').trim() || '#B8860B';
    const errorColor = '#FF6666'; 

    function displayMessage(message, isError = true) {
        validationMessage.textContent = message;
        
        if (isError) {
            validationMessage.style.color = 'white';
            validationMessage.style.borderColor = errorColor;
            validationMessage.style.backgroundColor = '#6d0f0f';
        } else {
            validationMessage.style.color = accentColor;
            validationMessage.style.borderColor = accentColor;
            validationMessage.style.backgroundColor = 'rgba(184, 134, 11, 0.1)';
        }

        validationMessage.classList.remove('hidden');
    }

    function hideMessage() {
        validationMessage.classList.add('hidden');
    }

    form.addEventListener('submit', (event) => {
        // 1. Stoppa först för att validera
        event.preventDefault(); 
        hideMessage();

        // 2. Validera namnet
        if (!nameInput.value.trim()) {
            displayMessage("Vänligen fyll i ditt fullständiga namn.");
            nameInput.focus();
            return; 
        }

        // 3. Validera e-post
        if (!emailInput.value.trim() || !emailInput.value.includes('@')) {
            displayMessage("Vänligen ange en giltig e-postadress.");
            emailInput.focus();
            return; 
        }

        // 4. Allt är OK! Skicka formuläret till Flask/Databasen nu:
        form.submit(); 
    });
});
