const body = document.getElementById('body');
const button = document.createElement('button');
button.innerText = 'POST';
body.appendChild(button);
let files = [];
getFilesInformationFromServer();
const ul = document.createElement('ul');
ul.innerText = 'Files';
body.appendChild(ul);

button.addEventListener('click', () => {
    sendFileInformationToServer({ id: 1, title: "Hello", location: "C:\\Users\\MRCPEX\\Downloads\\switch.png" });
});

async function sendFileInformationToServer(data) {
    try {
        // Send POST request to server to store file information
        const postResponse = await fetch('http://192.168.1.5:4060/download', {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });

        // Check if POST request was successful
        if (!postResponse.ok) {
            throw new Error('Failed to send file information to server.');
        }

        // Send GET request to trigger file download
        const getResponse = await fetch('http://192.168.1.5:4060/download');

        // Check if GET request was successful
        if (!getResponse.ok) {
            throw new Error('Failed to fetch file from server.');
        }

        // Trigger file download
        const blob = await getResponse.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = data.title; // Specify the file name
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
    } catch (error) {
        console.error('Error:', error.message);
    }
}

async function getFilesInformationFromServer() {
    try {
        const response = await fetch('http://192.168.1.5:4060/files');
        if (!response.ok) {
            throw new Error('Failed to fetch files information from server.');
        }
        const data = await response.json();
        files = data;
        console.log(files);
        // Populate the list of files here
        files.forEach((e) => {
            const { id, title, location } = e;
            const li = document.createElement('li');
            li.innerText = `${id}-${title}`;
            ul.appendChild(li);
            li.addEventListener('click', async () => {
                console.log(`Clicked file information: ${id}-${title}-${location}`);
                await sendFileInformationToServer({
                    id: id,
                    title: title,
                    location: location,
                });
            });
        });
    } catch (error) {
        console.error('Error:', error.message);
    }
}
