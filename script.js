document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('signup-form');
    const nameInput = document.getElementById('name');
    const emailInput = document.getElementById('email');
    const validationMessage = document.getElementById('validation-message');

    // Funktion för att visa meddelanden
    function displayMessage(message, isError = true) {
        validationMessage.textContent = message;
        validationMessage.style.color = isError ? 'var(--error-color)' : 'var(--green-glow)';
        validationMessage.style.borderColor = isError ? 'var(--error-color)' : 'var(--green-glow)';
        validationMessage.style.backgroundColor = isError ? '#330000' : 'var(--green-dark)';
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
        
        // 1. Visar ett framgångsmeddelande istället för att skicka till server
        displayMessage("Tack för din registrering! Du kommer snart att få en bekräftelse.", false);

        // 2. För en riktig webbsida skulle du skicka data här:
        /*
        const formData = new FormData(form);
        fetch('din_server_endpoint', {
            method: 'POST',
            body: formData
        })
        .then(response => {
            // Hantera serversvar
        });
        */

        // 3. Återställ formuläret efter en kort fördröjning
        setTimeout(() => {
            form.reset();
            hideMessage();
        }, 4000);
    });
});