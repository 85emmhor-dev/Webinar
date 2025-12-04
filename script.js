document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('signup-form');
    const nameInput = document.getElementById('name');
    const emailInput = document.getElementById('email');
    const validationMessage = document.getElementById('validation-message');

    // Hämta färger från CSS-variablerna (måste köras efter CSS laddats)
    const accentColor = getComputedStyle(document.documentElement).getPropertyValue('--accent-gold').trim() || '#B8860B';
    const errorColor = '#FF6666'; 

    // Funktion för att visa meddelanden
    function displayMessage(message, isError = true) {
        validationMessage.textContent = message;
        
        if (isError) {
            validationMessage.style.color = 'white'; // För mörk bakgrund
            validationMessage.style.borderColor = errorColor;
            validationMessage.style.backgroundColor = '#6d0f0f';
        } else {
            validationMessage.style.color = accentColor;
            validationMessage.style.borderColor = accentColor;
            validationMessage.style.backgroundColor = 'rgba(184, 134, 11, 0.1)';
        }

        validationMessage.classList.remove('hidden');
    }

    // Funktion för att dölja meddelanden
    function hideMessage() {
        validationMessage.classList.add('hidden');
    }

    form.addEventListener('submit', (event) => {
        // Förhindra standardinlämning
        event.preventDefault(); 
        hideMessage();

        // Enkel klientvalidering
        if (!nameInput.value.trim()) {
            displayMessage("Vänligen fyll i ditt fullständiga namn.");
            nameInput.focus();
            return;
        }

        if (!emailInput.value.trim() || !emailInput.value.includes('@')) {
            displayMessage("Vänligen ange en giltig e-postadress.");
            emailInput.focus();
            return;
        }

        // Om valideringen lyckas:
        
        // 1. Visar ett framgångsmeddelande
        displayMessage("Fantastiskt! Din plats är säkrad. Bekräftelse skickas till din e-post.", false);

        // 2. Återställ formuläret efter en kort fördröjning
        setTimeout(() => {
            form.reset();
            hideMessage();
        }, 5000);
    });
});