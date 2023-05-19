//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "hardhat/console.sol";


import "@openzeppelin/contracts/utils/Strings.sol";

contract myDurianContract{

    address payable public owner;

    constructor() {
       
        
    }
    uint256 public durianRec = 0 ; //durian total record count
    mapping(uint256 => Durian) public durian;

    enum DurianState{FARM, DISTRIBUTED , RETAILER , CUSTOMER}

    struct Durian{
        string durianID ; 
        string durianType; //based on the given durian tree then it will have the durian type auto 
        string durianFarm;
        string durianTree; // this can be made into option 
        uint256 qty;
        uint256 price; // add this price also 
        DurianState  durianState; 
        address ownership ; 
    }



    //only durian farm can add 
    function addDurian(string memory _durianType,string memory _durianFarm,string memory _durianTree,uint256  _qty,uint256 _price) public {
         //require a valid name
        require(bytes(_durianType).length > 0);
        require(bytes(_durianFarm).length > 0);
        require(bytes(_durianTree).length > 0);
        require(_qty > 0);

        //starts from 1 of the array 
        incrementDurianRec(); //increment the durian records total 

        //Initialise the state to 0 (Farm)
        durian[durianRec] = Durian(strConcat("D",uint2str(durianRec)), _durianType, _durianFarm, _durianTree, _qty , _price,DurianState(0),msg.sender);

    }

    //They need to based on the state to update
    function updateDurian(string memory userInputID,string memory _durianType,string memory _durianFarm,string memory _durianTree,uint256  _qty,uint256 _price,address newAddress) public {

        //search whether the user search durian ID is in here 
        uint256 durianArrayIndex = searchDurianIndex(userInputID);

        if(durianArrayIndex != 0 ){
            durian[durianArrayIndex] = Durian(userInputID, _durianType, _durianFarm, _durianTree, _qty , _price,durian[durianArrayIndex].durianState,newAddress);
        }
       
    } 

    function setDurianStateByDurianID(string memory _durianID ,uint256 _newState)public {
        uint256 durianIndex = searchDurianIndex(_durianID);

        if(durianIndex!=0){
        //set Durian state 
        Durian memory newDurian  = getDurianData(_durianID);

        newDurian.durianState = DurianState(_newState);

        //Update durian latest records 
        durian[durianIndex] = newDurian;
        }

    }

    function etherToWei(uint valueEther) public view returns (uint)
    {
       return valueEther*(10**18);
    }

    function getDurianData(string memory _durianID) public view returns (Durian memory){
        //make sure durian ID &7 must be less the durian records 
        require(bytes(_durianID).length > 0 );

        //find the index of the durian 
        uint256 index = searchDurianIndex(_durianID);

        if(index != 0 ){
            return durian[index]; 
        }
        else {
            Durian memory errorDurianRecord = Durian("No Records Found", "0", "0", "0", 0 , 0,DurianState(0),msg.sender);
            return errorDurianRecord;
        }
    }

    //function uint to string 
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
   
    //function for incrementDurianRecords
    function incrementDurianRec() internal{
        durianRec+=1;
    }

    //function for concatenation in string 
    function strConcat(string memory _a, string  memory _b, string  memory _c, string memory _d, string  memory _e) internal returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(string memory  _a, string memory  _b) internal returns (string memory) {
        return strConcat(_a, _b, "", "", "");
    }

    //function search durian index number by durianID
    function searchDurianIndex(string memory durianIDinput) public view returns (uint256){
        //0 is error 

        for(uint i = 1 ; i < durianRec+1 ; i++){
            //search whether which durian Records has the durianID input 
            if(keccak256(abi.encodePacked(durian[i].durianID))==keccak256(abi.encodePacked(durianIDinput))){
                //if search return index number 
                return i ; 
            }
        }

        //if cannot find 
        return 0; 

    }

    //check durian state is in durian farm
    function isDurianInFarm(string memory _durianID) public view returns (bool){
        Durian memory durian = getDurianData(_durianID);

        if(durian.durianState == DurianState.FARM){
            return true;
        }
        else {
            return false;
        }
    }

    function buyDurian(string memory _durianID)public payable{
        //_toReceiver is the owner of Durian 
        Durian memory localDurian = getDurianData(_durianID);
        uint256 index = searchDurianIndex(_durianID);
 
        address buyer = payable(msg.sender);
        address payable toReceiver = payable(localDurian.ownership);
        uint durianPrice = localDurian.price; 
        
        toReceiver.transfer(msg.value);

        //Update the durian ownership
        localDurian.ownership = msg.sender;
        durian[index] = localDurian;
        
    }





    //function for concatenation in string end 
    function checkDurianState(uint number) public returns (string memory ) {
        if(number == 0 ){
            return "FARM";
        }
        else if (number == 1){
            return "DISTRIBUTED";

        }else if (number == 2){
            return "RETAILER";

        }else if (number == 3){
            return "CUSTOMER";

        }
        else{
            //if the number is not 0 - 3 
            return "Error";
        }
        
       
    }


    //get durian total count of data
    function getDurianTotal() public view returns(uint256){
        return durianRec;
    }


    struct User{
        Position position; 
        string name; 
        string userID; 
    }

    enum Position{FARM_OWNER , DISTRIBUTER , RETAILER , CUSTOMER}

    mapping(address => User)  public userList;
    address [] public userAddressArray;

    function addUser(address _userAddress , uint256 pos , string memory _name) public{
        //Find duplication 
        bool addressRegisteredBefore = checkDuplicateUser(_userAddress);

        if(!addressRegisteredBefore){
        userList[_userAddress] = User(Position(pos) , _name,strConcat("U",uint2str(getUserLength()+1)));
        userAddressArray.push(_userAddress);
        }
    }

    function checkDuplicateUser(address _userAddress) public view returns (bool){
        bytes memory tempUserChecking = bytes(userList[_userAddress].name); 
        if(tempUserChecking.length == 0 ){
            //the current address does not appear in the userList 
            return false;
        }else{
            //already have this user
            return true;
        }
    }

    function updateUser(address _userAddress , uint256 pos , string memory _name) public{
        //Check the account exists
        bool addressRegisteredBefore = checkDuplicateUser(_userAddress);

        //if the account exists 
        if(addressRegisteredBefore){
        User memory tempLocal = userList[_userAddress];
        userList[_userAddress] = User(Position(pos) , _name,tempLocal.userID);
        }
    }

    function searchUser(address _userAddress)public view returns (User memory){
        return userList[_userAddress];
    }

    function getUserLength() public view returns(uint length){
        return userAddressArray.length;
    }

    function searchUserByIndex(uint index)public view returns(User memory){
        address localAddress = userAddressArray[index];
        return userList[localAddress];
    }

    function getUserAddressByIndex(uint index)public view returns(address){
        return userAddressArray[index];
    }

    function getPositionToString(uint index) public view returns(string memory){
        if(index == 0 ){
            return "FARM_OWNER";
        }else if (index == 1){
            return "DISTRIBUTER";
        }else if (index  == 2){
            return "RETAILER";
        }else if (index == 3){
            return "CUSTOMER";
        }
    }

    function getPositionByUserID(address _userAddress) public view returns (string memory){
        User memory userlocal = searchUser(_userAddress);

        if(userlocal.position == Position.FARM_OWNER){
            return "FARM_OWNER";
        }else if (userlocal.position == Position.DISTRIBUTER){
            return "DISTRIBUTER";
        }else if (userlocal.position == Position.RETAILER){
            return "RETAILER";
        }else if (userlocal.position == Position.CUSTOMER){
            return "CUSTOMER";
        }

    }


    struct Purchase{
        string purchaseID;
        uint256 purchaseTime;

        //Durian Details
        Durian durian; //keep durian records 

        //Buyer details (User can be only 2 distributer or customer)
        address buyerAddress;

        //distributed to which retails store (This only use for distributer
        bool retailGet; 
        address retailAddress;

        string reviewID;
        string reviewDescription;
        uint256 rating;
    }

    uint reviewLength = 0 ; 

    function addReview(string memory purchaseID , uint256 _rating , string memory desc)public {
        reviewLength=reviewLength+1;
        Purchase memory localPurchase = getPurchaseData(purchaseID);
        uint256 index = searchPurchaseIndex(purchaseID);
        localPurchase.rating = _rating;
        localPurchase.reviewDescription = desc;
        localPurchase.reviewID = strConcat("R", uint2str(reviewLength)); 
        
        purchaseList[index] = localPurchase;
        
    }


    //create a purchase Array
    Purchase[] public purchaseList;

    function addPurchase(string memory _durianID, address _buyerAddress) public {
        //check durianID existed && address given is registered 
        bool addressRegisteredBefore = checkDuplicateUser(_buyerAddress);

        if(searchDurianIndex(_durianID) != 0 && addressRegisteredBefore == true){
            
            //Generate purchaseID and purchaseTime
            string memory _purchaseID = strConcat("P",uint2str(getPurchaseLength()+1)); 
            uint256 _purchaseTime = block.timestamp; 
            
            //get durian records 
            Durian memory _durian = getDurianData(_durianID);

            address _retailAddress = 0x6C275cf03Cc78EFc642947a67F67C74fAeC2e5A4;
            
            //if not state 0 jiu the durian is purchase by other user 
            if(_durian.durianState == DurianState.FARM){
         
                //Push into the purchaseList
                purchaseList.push(Purchase(_purchaseID,_purchaseTime,_durian,_buyerAddress,false ,_retailAddress,"","",0));
            }

            //Change durian state inside durian List
            setDurianStateByDurianID(_durianID , 1);
        }
    } 

    

    function searchPurchaseIndex(string memory purchaseID) public view returns(uint256){
        //0 is error 

        for(uint i = 0 ; i < purchaseList.length ; i++){
            //search whether which durian Records has the purchaseID input 
            if(keccak256(abi.encodePacked(purchaseList[i].purchaseID))==keccak256(abi.encodePacked(purchaseID))){
                //if search return index number 
                return i ; 
            }
        }

        return 0 ; 

    }

    //get durian data inside purchaseID
    function getPurchaseDurianData(string memory _purchaseID)public view returns(Durian memory){
        Purchase memory localPurchase = getPurchaseData(_purchaseID);
        return localPurchase.durian;
    }


    function getPurchaseData(string memory _purchaseID)public view returns (Purchase memory){
        uint index = searchPurchaseIndex(_purchaseID);
        return purchaseList[index];
    }

    function getPurchaseLength ()public view returns(uint256 length){
        return purchaseList.length;
    }

    
    //sell the durian to retailer
    function updatePurchase(string memory _purchaseID,address _retailAddress , uint256  _newPrice) public {
        //add retailer address inside the 
        uint256 index = searchPurchaseIndex(_purchaseID);
        Purchase memory _purchase = getPurchaseData(_purchaseID);

        _purchase.retailGet = true ; 
        _purchase.retailAddress = _retailAddress;

        //add altered data into the purchase list 
        purchaseList[index] = _purchase;

        //change durian price 
        Durian memory _durian = getPurchaseDurianData(_purchaseID);
        _durian.durianState = DurianState.DISTRIBUTED;

        _durian.price = _newPrice ; 

        uint256 durianIndex = searchDurianIndex(_durian.durianID);

        //add back into durian list 
        durian[durianIndex] = _durian;
       
    }


    //-----------------------------Added new 
    function listDurianToSell(string memory _durianID,  address newOwnership)public{
        //find the durianID
            //change ownership  
            //change state -> 

        uint256 index = searchDurianIndex(_durianID);
        Durian memory _durian = getDurianData(_durianID);

        //check when the durian are from distributed

        if(_durian.durianState == DurianState.DISTRIBUTED){
            //change state and change price
            _durian.durianState = DurianState.RETAILER;
            _durian.ownership = newOwnership;

            durian[index] = Durian(_durian.durianID,  _durian.durianType, _durian.durianFarm, _durian.durianTree ,_durian.qty ,_durian.price,_durian.durianState, _durian.ownership);
        }
    }

    //use for customer to add their purchase
    function addPurchaseCustomer(string memory _durianID, address _customerAddress ,uint256 _qty) public {
        //check durianID existed && address given is registered 
        bool addressRegisteredBefore = checkDuplicateUser(_customerAddress);

        if(searchDurianIndex(_durianID) != 0 && addressRegisteredBefore == true){
            
            //Generate purchaseID and purchaseTime
            string memory _purchaseID = strConcat("P",uint2str(getPurchaseLength()+1)); 
            uint256 _purchaseTime = block.timestamp; 
            
            //get durian records 
            Durian memory _durian = getDurianData(_durianID);

            //detect the quantity must not be bigger than current quantity
            if(_durian.qty > _qty){
                //Durian records put the Qty 
                _durian.qty = _qty;
                _durian.price = _qty * _durian.price;

                //this address act as dummy only 
                address _retailAddress = 0x6C275cf03Cc78EFc642947a67F67C74fAeC2e5A4;
                
                //the state must be retailer only can buy 
                if(_durian.durianState == DurianState.RETAILER){
            
                    //Push into the purchaseList
                    purchaseList.push(Purchase(_purchaseID,_purchaseTime,_durian,_customerAddress,false ,_retailAddress,"","",0));
                }
                
                //Update the qty of the durian records 
                Durian memory _durianUpdateQtyObject = getDurianData(_durianID);
                uint256 getIndex = searchDurianIndex(_durianID);

                //deduct the qty that have been bought buy the user
                _durianUpdateQtyObject.qty = _durianUpdateQtyObject.qty - _qty;

                //add back into the array 
                durian[getIndex] = _durianUpdateQtyObject;
            }



        }
    } 

    

   

    

    

}