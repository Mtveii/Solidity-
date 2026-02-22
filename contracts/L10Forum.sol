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

    error NotOwner(address from);

    Post[] posts;
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
