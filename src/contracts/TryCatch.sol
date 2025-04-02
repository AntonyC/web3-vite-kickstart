//SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract WillThrow {
    error ThisIsACustomError(string, string);

    function aFunction() public pure {
        // require(false, "Antony: error by require");
        // assert(false);
        revert ThisIsACustomError("Antony", "customed error message");
    }
}

contract ErrorHandling {
    event ErrorLogging(string reason);
    event ErrorLogCode(uint reason);
    event ErrorLogBytes(bytes reason);

    function catchError() public {
        WillThrow will = new WillThrow();
        try will.aFunction() {
            //here we could do something if it works
        } catch Error(string memory reason) { // get error by require
            emit ErrorLogging(reason);
        } catch Panic(uint errorCode){ // get error by assert
            emit ErrorLogCode(errorCode);
        } catch (bytes memory lowLevelData){ // get error by custom
            emit ErrorLogBytes(lowLevelData);
        }
    }
}
