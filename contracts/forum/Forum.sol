// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 < 0.9.0;

import "hardhat/console.sol";

contract Forum{

    event PostCreated(address author, uint timestamp);
    event PostsCleared(address owner, uint postsLength);

    struct Post{
        string message;
        address author;
        uint timestamp;
        uint like;
        bool deleted;
        uint index;
    }

    struct Media{
        string url;
        string description;
        address uploader;
        uint timestamp;
        bool isDeleted;
        uint index;
    }

    error NotOwner(address from);

    Post[] posts;
    Media[] medias;
    // post index => (address => liked)
    mapping(uint => mapping(address => bool)) public liked;
    address owner;

    constructor(){
        owner = msg.sender;
        console.log("Forum successfuly created. Owner address: ", msg.sender);
    }

    modifier OnlyOwner() {
        require(msg.sender == owner, NotOwner(msg.sender));
        _;
    }

    function clear_posts() public OnlyOwner(){
        uint posts_quantity = posts.length;
        emit PostsCleared(msg.sender, posts_quantity);
        delete posts;
    }

    function create_post(string memory message)public returns(bool){
        posts.push(
            Post(
                message,
                msg.sender,
                block.timestamp,
                0,
                false,
                posts.length
            )
        );

        emit PostCreated(msg.sender, block.timestamp);
        return true;
    }

    function get_post(uint index) public view returns(Post memory){
        require(index < posts.length, "Too big number");

        return posts[index];
    }

    function get_posts()public view returns(Post[] memory){
        uint count = 0;
        for(uint i = 0; i < posts.length; i++){
            if(!posts[i].deleted){
                count++;
            }
        }

        Post[] memory result = new Post[](count);
        uint j = 0;
        for(uint i = 0; i < posts.length; i++){
            if(!posts[i].deleted){
                result[j] = posts[i];
                j++;
            }
        }

        return result;
    }

    function get_posts_by_author(address author) public view returns(Post[] memory){
        uint count = 0;
        for(uint i = 0; i < posts.length; i++){
            if(!posts[i].deleted && posts[i].author == author){
                count++;
            }
        }

        Post[] memory result = new Post[](count);
        uint j = 0;
        for(uint i = 0; i < posts.length; i++){
            if(!posts[i].deleted && posts[i].author == author){
                result[j] = posts[i];
                j++;
            }
        }

        return result;
    }

    event PostDeleted(address indexed author, uint index);
    event LikeToggled(address indexed liker, uint index, bool likedState);
    event MediaCreated(address indexed uploader, uint index, string url);
    event MediaDeleted(address indexed uploader, uint index);

    error NotAuthor(address from);

    function delete_post(uint index) public returns(bool){
        require(index < posts.length, "Too big number");
        Post storage p = posts[index];
        require(!p.deleted, "Already deleted");
        require(p.author == msg.sender, NotAuthor(msg.sender));

        p.deleted = true;
        emit PostDeleted(msg.sender, index);
        return true;
    }

    function add_media(string memory url, string memory description) public returns(bool){
        medias.push(
            Media(
                url,
                description,
                msg.sender,
                block.timestamp,
                false,
                medias.length
            )
        );

        emit MediaCreated(msg.sender, medias.length - 1, url);
        return true;
    }

    function get_medias() public view returns(Media[] memory){
        uint count = 0;
        for(uint i = 0; i < medias.length; i++){
            if(!medias[i].isDeleted){
                count++;
            }
        }

        Media[] memory result = new Media[](count);
        uint j = 0;
        for(uint i = 0; i < medias.length; i++){
            if(!medias[i].isDeleted){
                result[j] = medias[i];
                j++;
            }
        }

        return result;
    }

    function get_medias_by_uploader(address uploader) public view returns(Media[] memory){
        uint count = 0;
        for(uint i = 0; i < medias.length; i++){
            if(!medias[i].isDeleted && medias[i].uploader == uploader){
                count++;
            }
        }

        Media[] memory result = new Media[](count);
        uint j = 0;
        for(uint i = 0; i < medias.length; i++){
            if(!medias[i].isDeleted && medias[i].uploader == uploader){
                result[j] = medias[i];
                j++;
            }
        }

        return result;
    }

    error NotUploader(address from);

    function delete_media(uint index) public returns(bool){
        require(index < medias.length, "Too big number");
        Media storage m = medias[index];
        require(!m.isDeleted, "Already deleted");
        require(m.uploader == msg.sender, NotUploader(msg.sender));

        m.isDeleted = true;
        emit MediaDeleted(msg.sender, index);
        return true;
    }

    function toggle_like(uint index) public returns(bool){
        require(index < posts.length, "Too big number");
        Post storage p = posts[index];
        require(!p.deleted, "Post deleted");

        if(liked[index][msg.sender]){
            liked[index][msg.sender] = false;
            if(p.like > 0) p.like -= 1;
            emit LikeToggled(msg.sender, index, false);
        } else {
            liked[index][msg.sender] = true;
            p.like += 1;
            emit LikeToggled(msg.sender, index, true);
        }

        return true;
    }
    

}
