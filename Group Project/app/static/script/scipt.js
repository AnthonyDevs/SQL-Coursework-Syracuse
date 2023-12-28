document.getElementById('registrationForm').addEventListener('submit', function(event) {
    event.preventDefault();

    const userData = {
        userName: document.getElementById('userName').value,
        userAge: document.getElementById('userAge').value,
        userGender: document.getElementById('userGender').value,
        fitnessFocus: document.getElementById('fitnessFocus').value,
        userZipCode: document.getElementById('userZipCode').value
        // Add other fields as needed
    };

    // Send this data to Flask backend
    fetch('/register', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(userData)
    })
    .then(response => response.json())
    .then(data => {
        if(data.status === 'success') {
            findTrainerMatches(userData);
        } else {
            // Handle registration failure
        }
    })
    .catch(error => console.error('Error:', error));
});

function findTrainerMatches(userData) {
    // Logic to request and display matching trainers
    fetch('/find_trainer', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ userFitnessFocus: userData.fitnessFocus })
    })
    .then(response => response.json())
    .then(matches => {
        displayTrainerMatches(matches);
    })
    .catch(error => console.error('Error:', error));
}

function displayTrainerMatches(matches) {
    const resultsDiv = document.getElementById('matchResults');
    resultsDiv.innerHTML = '';

    matches.forEach(match => {
        resultsDiv.innerHTML += `<div>
            <h3>${match.trainer_name}</h3>
            <p>Availability: ${match.availability}</p>
            <p>Rate: $${match.rate}/hour</p>
            <!-- Add other details as needed -->
        </div>`;
    });
}
