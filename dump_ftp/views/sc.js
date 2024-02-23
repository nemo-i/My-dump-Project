let data = [
    {
        dir: 'books',
        files: [
            {
                name: "CISSP",
                path: "F\\h"
            }
        ],
    },
    {
        dir: 'videos',
        files: [
            {
                name: "CISSP",
                path: "F\\h"
            }
        ],
    }
];

document.addEventListener("DOMContentLoaded", function () {
    const body = document.getElementById("body");
    const ul = document.createElement("ul");
    body.appendChild(ul);

    data.forEach((e) => {
        const li = document.createElement("li");
        const directoryName = document.createElement("span");
        directoryName.innerText = e.dir;
        directoryName.style.cursor = "pointer";
        directoryName.addEventListener("click", function () {
            filesUl.style.display = filesUl.style.display === "none" ? "block" : "none";
        });
        li.appendChild(directoryName);

        const filesUl = document.createElement("ul");
        e.files.forEach((file) => {
            const fileLi = document.createElement("li");
            fileLi.innerText = `${file.name} - ${file.path}`;
            fileLi.style.cursor = "pointer";
            fileLi.addEventListener("click", function () {
                // Send a POST request to the server
                fetch('/download', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({ path: file.path })
                })
                    .then(response => {
                        // Handle response, e.g., show a message to the user
                        console.log('File download initiated');
                    })
                    .catch(error => {
                        // Handle error
                        console.error('Error occurred:', error);
                    });

                // Change color of the clicked item
                fileLi.classList.add('clicked');
            });
            filesUl.appendChild(fileLi);
        });

        li.appendChild(filesUl);
        ul.appendChild(li);
    });
});
