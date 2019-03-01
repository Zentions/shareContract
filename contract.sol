pragma solidity ^0.5.2;
contract share{
    struct software{
        bool exist;
        address owner;
        string date;
        string name;
        uint weight;
        uint score;
        string start;
    }
    struct user{
        address u_address;
        uint score;
        string name;
        string pass;
        string server_mac;
        string server_ip;
        bool isShare;
        uint count;//the number of user that  use software
        uint moneyPerHour;
        string cpu;
        string men_size;
    }
    struct record{
        string server_mac;
        string server_ip;
        address server_address;
        uint start_timestap;
        uint end_timestap;
        string client_mac;
        string client_ip;
        address client_address;
        uint total_time;
        uint money;
        uint num;//hours
    }
   
    mapping(string =>record) records;
    address[] address_array;
    mapping(address => user)  users;
    mapping(address => software[])  user_software;
    mapping(address => uint) user_software_len;
    
    constructor() public{
        user memory u;// =user(msg.sender,100,"123456","sharehome");
        u.u_address = msg.sender;
        u.score = 650;
        u.name = "share";
        u.pass = "123456";
        users[msg.sender] = u;
        address_array.push(msg.sender);
    }
    function storeUser() public {
        if(users[msg.sender].u_address == address(0)){
            user memory u;//  = user(msg.sender,100,name,pass);
            u.u_address = msg.sender;
            u.score = 650;
            u.name = "share";
            u.pass = "123456";
            u.count = 0;
            users[msg.sender] = u;
            address_array.push(msg.sender);
        }
    }
    function isUserRegister(address add) public view returns(bool){
        if(users[add].u_address == address(0)) return false;
        else return true;
    }
    function searchUserLength() view public returns(uint){
        return address_array.length;
    }
    function fetchUser(uint index) public view returns(address,bool){
        address  u_add = address_array[index];
        bool is_share = users[u_add].isShare;
        return (u_add,is_share);
    }
    function fetchUserBySoftware(string memory name) view public returns(uint findAddressLen,address[50] memory addresses){
        findAddressLen = 0;
        uint len = address_array.length;
        for(uint i=0;i<len;i++){
           if(users[address_array[i]].isShare){
               software[] memory s = user_software[address_array[i]];
               uint sLen = s.length;
               for(uint j=0;j<sLen;j++){
                   if(hashCompareWithLengthCheckInternal(name,s[j].name)){
                       address findAddress = address_array[i];
                       addresses[findAddressLen] = findAddress;
                       findAddressLen++;
                       if(findAddressLen==50) break;
                       break;
                    }
                }
           }
        }
        
    }
    function fetchUserInfo(address add) public view returns(string memory,string memory,string memory,
    uint,uint,string memory,string memory){
        user memory u = users[add];
        return (u.server_mac,u.server_ip,u.pass,u.score,u.moneyPerHour,u.cpu,u.men_size);
    }
    function updateScore(address server_address,uint[] memory indexs,uint[] memory scores) public {
        require(indexs.length==scores.length);
        software[] storage softwares = user_software[server_address];
        uint client_score = users[msg.sender].score;
        uint server = 0;
        uint client = 0;
        for(uint i=0;i<indexs.length;i++){
            require(indexs[i]<softwares.length);
            require(scores[i]<=1000);
            software storage s = softwares[indexs[i]];
            s.score = (s.score*s.weight+ scores[i]*client_score)/(s.weight+client_score);
            s.weight += client_score;
            server += scores[i];
            client += (scores[i]-s.score)*(scores[i]-s.score);
        }
        server = server/indexs.length;
        client = client/indexs.length;
        //server trust
        if(server>0 && server<=200) users[server_address].score -= 6;
        else if(server>200 && server<=400) users[server_address].score -= 4;
        else if(server>400 && server<=600) users[server_address].score -= 2;
        else if(server>600 && server<=700) users[server_address].score -= 0;
        else if(server>700 && server<=800) users[server_address].score += 1;
        else if(server>800 && server<=900) users[server_address].score += 2;
        else users[server_address].score += 3;
        if(users[server_address].score<0)users[server_address].score=0;
        if(users[server_address].score>1000)users[server_address].score=1000;
        //client trust
        if(client>0 && client <=2500) users[msg.sender].score += 2;
        else if(client>2500 && client <=10000) users[msg.sender].score += 1;
        else if(client>10000 && client <=40000) users[msg.sender].score += 0;
        else if(client>40000 && client <=90000) users[msg.sender].score -= 4;
        else users[msg.sender].score -= 6;
        if(users[msg.sender].score<0)users[msg.sender].score=0;
        if(users[msg.sender].score>1000)users[msg.sender].score=1000;
    }
    function modifyPass(string memory pass) public{
        user storage u = users[msg.sender];
        u.pass = pass;
    }
    function getUserPass(address add) public view returns(string memory){
        return users[add].pass;
    }
    function storeSoftWare(string memory date,string memory name,string memory start) public{
        software memory soft = software(true,msg.sender,date,name,1000,600,start);
        user_software[msg.sender].push(soft);
        user_software_len[msg.sender]++;
    }
    function hashCompareWithLengthCheckInternal(string memory a, string memory b) internal pure returns (bool) {
        if (bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(abi.encode(a)) == keccak256(abi.encode(b));
        }
    }
    function deleteSoftWare(uint index) public{
        software[] storage softwares  = user_software[msg.sender];
        softwares[index].exist = false;
        user_software_len[msg.sender]--;
    }
    function getSoftWare(address add,uint index) public view returns( bool ,address ,string memory,
        string memory ,uint ,string memory ){
            require(index < user_software[add].length);
            software memory soft = user_software[add][index];
            return (soft.exist,soft.owner,soft.date,soft.name,soft.score,soft.start);
    }
    function getSoftWareLenth(address add) public view returns(uint trueLen,uint falseLen){
        falseLen = user_software[add].length;
        trueLen = user_software_len[add];
    }
    function firstStoreRecord(string memory key,string memory server_mac,string memory server_ip,
     address payable server_address,string memory client_mac, string memory client_ip, 
     address client_address,uint start_timestap) public payable{
        require(users[server_address].isShare==true);
        uint moneyPerHour = users[server_address].moneyPerHour;
        require(msg.sender.balance >= (moneyPerHour+1000000000000000000));
        require(msg.value >= moneyPerHour);
        require(server_address !=address(0));
        server_address.transfer(msg.value);
        record memory rr;
        rr.num = 1;
        rr.server_mac = server_mac;
        rr.server_ip = server_ip;
        rr.server_address = server_address;
        rr.start_timestap = start_timestap;
        rr.client_address = client_address;
        rr.client_ip = client_ip;
        rr.client_mac = client_mac;
        records[key] = rr;
        users[server_address].count++;
    }
    function hasEnoughMoney(address server_address,address client_address) public view returns(bool){
        uint moneyPerHour = users[server_address].moneyPerHour;
        return client_address.balance > (moneyPerHour+1000000000000000000);
    }
    function continueToPay(string memory key,address payable server_address) public payable{
        uint moneyPerHour = users[server_address].moneyPerHour;
        require(msg.sender.balance >= (moneyPerHour+1000000000000000000));
        require(msg.value >= moneyPerHour);
        require(server_address !=address(0));
        server_address.transfer(msg.value);
        record storage rr = records[key];
        rr.num++;
    }
    function endStoreRecord(string memory key,address server_address,uint end_timestap,uint total_time,
        uint money) public {
            record storage rr = records[key];
            rr.end_timestap = end_timestap;
            rr.total_time = total_time;
            rr.money = money;
            users[server_address].count--;
    }
    function getMoneyPerHour(address add) view public returns(uint){
        return users[add].moneyPerHour;
    }
    function getRecordByKey(string memory key) view public returns(string memory server_mac,
    string memory server_ip,address server_address,uint start_timestap,uint money){
        record memory rr = records[key];
        return (rr.server_mac,rr.server_ip,rr.server_address,rr.start_timestap,rr.money);
    }
    function pendShare(string memory server_mac,string memory server_ip,uint moneyPerHour,
    string memory cpu,string memory size ) public{
        user storage u = users[msg.sender];
        u.server_ip = server_ip;
        u.server_mac = server_mac;
        u.isShare = true;
        u.moneyPerHour = moneyPerHour;
        u.cpu = cpu;
        u.men_size = size;
    }
    function endShare() public{
       require(users[msg.sender].count==0);        
       user storage u = users[msg.sender];
       u.isShare = false;
    }
    function canUseNow(string memory key) view public returns(bool){
        if(records[key].server_address==address(0)) return false;
        else return true;
    }
    function getUserState(address add) view public returns(bool,uint){
        return (users[add].isShare,users[add].count);
    }
}

