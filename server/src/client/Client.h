
#ifndef _CLIENT_H_
#define _CLIENT_H_

#include <iostream>
#include <thread>
#include <atomic>
#include <vector>
#include <chrono>

#include <json/json.h>

#include "../network/Network.h"
#include "../utilities/Utility.h"
#include "../database/Database.h"

enum class ClientStatus : int {DEAD=0,NOT_AUTHORIZED,AUTHORIZED};

class Client{
public:
    Client(BIO *sock);
    ~Client();
    
    void start();
    bool close();
    
    ClientStatus getStatus();
    bool isRunning();
    
private:
    Client();
    void run();
    
    void authorize();
    void login(Json::Value &val);
    void logout(Json::Value &val);
    void reg(Json::Value &val);
    void verify(Json::Value &val);
    void renew(Json::Value &val);
    void remove(Json::Value &val);
    
    Json::FastWriter m_writer;
    
    Network *m_network;
    Database *m_database;
    std::thread m_thread;
        
    std::atomic<ClientStatus> m_cs;
    std::atomic<bool> m_isRunning;
};

#endif /* _CLIENT_H_ */
 
