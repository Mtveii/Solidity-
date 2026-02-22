// import Contract from 'web3-eth-contract'

const contract_address = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

let web3;
let contract;
let current_account;

document.addEventListener('DOMContentLoaded', () => {
    const connectionButton = document.getElementById("connectionButton");
    connectionButton.addEventListener("click", connectWallet);

    const makePostButton = document.getElementById("makePostButton");
    makePostButton.addEventListener('click', makePost);

    const getPostsButton = document.getElementById("getPostsButton");
    getPostsButton.addEventListener('click', getPost);

    const clearPostButton = document.getElementById("clearPostButton");
    clearPostButton.addEventListener('click', clearPosts);

    const filterButton = document.getElementById("filterButton");
    filterButton.addEventListener('click', () => renderPosts());

    const myPostsButton = document.getElementById("myPostsButton");
    myPostsButton.addEventListener('click', () => {
        const authorFilter = document.getElementById('authorFilter');
        authorFilter.value = current_account || '';
        renderPosts();
    });

    // Media UI handlers
    const addMediaButton = document.getElementById('addMediaButton');
    if(addMediaButton) addMediaButton.addEventListener('click', addMedia);

    if (window.ethereum) {
        web3 = new Web3(window.ethereum);
        // console.log("ABI: ", abi)
        contract = new web3.eth.Contract(abi, contract_address);

        window.ethereum.on("accountsChanged", (accounts) => {
            if (accounts.length > 0) {
                current_account = accounts[0];
                enterToDapp();
            }
        })
    } else alert("Install web3 provider(MetaMask, Infura, etc.)");

    contract.events.PostCreated({ fromBlock: 'latest' })
        .on("data", event=>{
            console.log("PostCreated: ", event.returnValues);
            renderPosts();
        })

    contract.events.PostsCleared({ fromBlock: 'latest' })
        .on("data", event=>{
            console.log("PostsCleared: ", event.returnValues);
            renderPosts();
        })
    contract.events.PostDeleted({ fromBlock: 'latest' })
        .on('data', e=>{
            console.log('PostDeleted', e.returnValues);
            renderPosts();
        })

    contract.events.LikeToggled({ fromBlock: 'latest' })
        .on('data', e=>{
            console.log('LikeToggled', e.returnValues);
            renderPosts();
        })
    contract.events.MediaCreated({ fromBlock: 'latest' })
        .on('data', e=>{
            console.log('MediaCreated', e.returnValues);
            renderMedias();
        })
    contract.events.MediaDeleted({ fromBlock: 'latest' })
        .on('data', e=>{
            console.log('MediaDeleted', e.returnValues);
            renderMedias();
        })
})

const enterToDapp = () => {
    const accountLabel = document.getElementById('accountLabel');
    accountLabel.hidden = false;
    accountLabel.textContent = current_account;
    accountLabel.style.color = 'darkgreen';
    const dapp = document.getElementById("dapp");
    dapp.hidden = false;

    renderPosts();
}

const addMedia = async () => {
    try{
        const fileInput = document.getElementById('mediaFile');
        const urlInput = document.getElementById('mediaUrl');
        const descInput = document.getElementById('mediaDesc');

        let url = urlInput.value.trim();
        const description = descInput.value || '';

        if(!url && fileInput.files && fileInput.files[0]){
            // read file as data URL
            url = await new Promise((res, rej)=>{
                const fr = new FileReader();
                fr.onload = ()=> res(fr.result);
                fr.onerror = rej;
                fr.readAsDataURL(fileInput.files[0]);
            });
        }

        if(!url) return alert('Provide image file or URL');

        await contract.methods.add_media(url, description).send({ from: current_account });
        // UI will update via event, but force render as fallback
        renderMedias();
        // clear inputs
        urlInput.value = '';
        descInput.value = '';
        fileInput.value = '';
    }catch(e){ console.error(e); alert('Add media failed'); }
}

const renderMedias = async () => {
    try{
        const uploaderFilter = document.getElementById('authorFilter').value.trim();
        let medias;
        if(uploaderFilter){
            medias = await contract.methods.get_medias_by_uploader(uploaderFilter).call();
        } else {
            medias = await contract.methods.get_medias().call();
        }

        const container = document.getElementById('medias');
        while(container.firstChild) container.removeChild(container.firstChild);

        if(!medias || medias.length === 0){
            const p = document.createElement('p'); p.textContent = 'No images'; container.appendChild(p); return;
        }

        for(const m of medias){
            const card = document.createElement('div'); card.className = 'post-card';
            const header = document.createElement('div'); header.className = 'post-header';
            const uploader = document.createElement('div'); uploader.innerHTML = `<span class="author">${m.uploader}</span>`;
            const time = document.createElement('div'); time.textContent = new Date(Number(m.timestamp) * 1000).toLocaleString();
            header.appendChild(uploader); header.appendChild(time);

            const img = document.createElement('img'); img.src = m.url; img.style.maxWidth = '100%'; img.style.borderRadius='6px';
            const desc = document.createElement('div'); desc.className = 'post-message'; desc.textContent = m.description || '';

            const actions = document.createElement('div'); actions.className = 'post-actions';
            const delBtn = document.createElement('button'); delBtn.textContent = 'Delete';
            if(current_account && m.uploader.toLowerCase() === current_account.toLowerCase()){
                delBtn.addEventListener('click', async ()=>{
                    if(!confirm('Delete this image?')) return;
                    try{ await contract.methods.delete_media(m.index).send({ from: current_account }); renderMedias(); }catch(e){ console.error(e); alert('Delete failed'); }
                });
            } else {
                delBtn.disabled = true;
            }

            actions.appendChild(delBtn);

            card.appendChild(header); card.appendChild(img); card.appendChild(desc); card.appendChild(actions);
            container.appendChild(card);
        }
    }catch(e){ console.error(e); }
}

const connectWallet = async () => {
    if (window.ethereum) {
        try {
            const accounts = await window.ethereum.request({
                method: "eth_requestAccounts"
            }).catch((error) => {
                if (error.code === 4001) {
                    alert("User canceled transaction");
                }
            })
            console.log(accounts);
            current_account = accounts[0];
            enterToDapp();
        }
        catch (error) {
            console.error(error);
        }
    }
    else alert("Install web3 provider(MetaMask, Infura, etc.)");
}

const makePost = async () => {
    try {
        const input = document.getElementById("postInput");
        const message = input.value;
        if (!message) return alert("Message empty");

        const tx = await contract.methods.create_post(message).send({ from: current_account });
        console.log("Transact: ", tx);
        input.value = "";
        renderPosts();
    } catch (error) {
        console.error("Create error: ", error);
        alert("Create post error. See console logs");
    }
}

const getPost = async () => {
    try {
        // console.log(await contract.options.address);
        const post = await contract.methods.get_post(0).call();
        console.log(post);
    } catch (error) {
        console.error("Get posts error: ", error);
        alert("Get posts error. See console logs");
    }
}

const renderPosts = async () => {
    try {
        const authorFilter = document.getElementById('authorFilter').value.trim();
        let posts;
        if(authorFilter){
            posts = await contract.methods.get_posts_by_author(authorFilter).call();
        } else {
            posts = await contract.methods.get_posts().call();
        }
        const container = document.getElementById("posts");

        while(container.firstChild){
            container.removeChild(container.firstChild);
        }
        if(!posts || posts.length === 0){
            const p = document.createElement("p");
            p.textContent = "No posts to show";

            container.appendChild(p);
            return;
        }

        for(const post of posts){
            const div = document.createElement('div');
            div.className = 'post-card';

            const header = document.createElement('div');
            header.className = 'post-header';
            const author = document.createElement('div');
            author.innerHTML = `<span class="author">${post.author}</span>`;
            const time = document.createElement('div');
            time.textContent = new Date(Number(post.timestamp) * 1000).toLocaleString();
            header.appendChild(author);
            header.appendChild(time);

            const message = document.createElement('div');
            message.className = 'post-message';
            message.textContent = post.message;

            const actions = document.createElement('div');
            actions.className = 'post-actions';

            const likesLabel = document.createElement('span');
            likesLabel.textContent = `Likes: ${post.like}`;

            const likeBtn = document.createElement('button');
            likeBtn.textContent = 'Like';
            // check if current user liked
            if(current_account){
                try{
                    const likedState = await contract.methods.liked(post.index, current_account).call();
                    likeBtn.textContent = likedState ? 'Unlike' : 'Like';
                }catch(e){ console.warn('liked call failed', e); }
            }

            likeBtn.addEventListener('click', async ()=>{
                try{
                    await contract.methods.toggle_like(post.index).send({ from: current_account });
                    renderPosts();
                }catch(e){ console.error(e); alert('Like failed'); }
            });

            actions.appendChild(likesLabel);
            actions.appendChild(likeBtn);

            // show delete only to author
            if(current_account && post.author.toLowerCase() === current_account.toLowerCase()){
                const delBtn = document.createElement('button');
                delBtn.textContent = 'Delete';
                delBtn.addEventListener('click', async ()=>{
                    if(!confirm('Delete this post?')) return;
                    try{
                        await contract.methods.delete_post(post.index).send({ from: current_account });
                        renderPosts();
                    }catch(e){ console.error(e); alert('Delete failed'); }
                });
                actions.appendChild(delBtn);
            }

            div.appendChild(header);
            div.appendChild(message);
            div.appendChild(actions);

            container.appendChild(div);
        }

    } catch (error) {
        console.error("Render error: ", error);
        alert("Render error. See console logs.")
        
    }
}

const clearPosts = async () => {
    try {
        await contract.methods.clear_posts().send({ from: current_account });
    } catch (error) {
        console.error("Clear posts error: ", error);
        alert("Clear posts error. See console logs.");
    }
}
