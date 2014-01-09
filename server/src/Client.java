package pack;

import java.io.*;
import java.net.*;
import java.util.*;
import java.security.*;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.Statement;

import org.json.simple.*;
import org.json.simple.parser.*;

@SuppressWarnings("unchecked")
public class Client extends Thread {
    public enum ClientStatus { NOT_AUTHORIZED, AUTHORIZED, DEAD}

    ClientStatus cs;
    
    int userID;
    String sessionID;
    String email = "";
    
    Connection conn = null;
    Statement stmt = null;
    
    Network network;
     
    Client()
    {
        
    }

    Client(Socket sock){
        this.cs = ClientStatus.NOT_AUTHORIZED;
        this.network = new Network(sock);
        this.network.start();
    }
    
    public boolean isDead()
    {
        if(cs == ClientStatus.DEAD)
            return true;
        else
            return false;
    }
    
    public void dbLogin()
    {
        try{
            System.out.print("Connecting to database... ");
            String url = "jdbc:mysql://127.0.0.1:3306/onebrown";
            String user = "root";
            String pass = "df9qfEZVoXl/8MW4";
            conn = DriverManager.getConnection(url,user,pass);
        } catch(SQLException ex) {
            System.out.println("error.");
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            cs = ClientStatus.DEAD;
        }
        System.out.println("done!");
    }

    public void run()
    {
        dbLogin();
        authorize();
        
        cs = ClientStatus.DEAD;
    }

    public void authorize()
    {
        while(cs == ClientStatus.NOT_AUTHORIZED){
            String msg = null;
            while(msg == null){
                JSONObject json = new JSONObject();
                json.put("message","login_or_register");
                network.sendJSONObject(json,false);    
            
                //json = (JSONObject)network.getJSONObject(false);
                json = network.pullJSONObject();
                if(json == null)
                    continue;
                msg = (String)json.get("message");
            }
            if(msg.equals("register"))
                register();
            else if(msg.equals("login"))
                login();
        }
    }

    public void login()
    {
        JSONObject json = new JSONObject();
        MessageDigest md = null;
        ResultSet rs = null;
        String user = null;
        String pass = null;
        String sID  = null;
        String sql = "";
        byte hash[] = null;
        byte salt[] = null;
        byte digest[] = null;
        
        //get hashing algorithm 
        try{
            md = MessageDigest.getInstance("SHA-256");
        } catch(NoSuchAlgorithmException e){}
        
        boolean firstTime = true;
        while( (user == null || pass == null) && sID == null ){
            if(!firstTime){
                sendAuth(false);
                return;
            }
            firstTime = false;
            json = network.pullJSONObject();
            if(json == null)
                continue;
            user = (String)json.get("user");
            pass = (String)json.get("pass");
            sID  = (String)json.get("session");
        }
        
        if(sID != null){
            
            try{
                stmt = conn.createStatement();
                sql = "SELECT * FROM users WHERE session='" + sID + "'";
                rs = stmt.executeQuery(sql);
                if(rs.next()){
                    userID = rs.getInt("id");
                    email = rs.getString("email");
                    hash = rs.getBytes("hash");
                    salt = rs.getBytes("salt");
                    sessionID = rs.getString("session");
                    sendAuth(true);
                    return;
                }else{
                    sendAuth(false);
                    return;
                }
            } catch(SQLException e) {}
        }
        
        //clean input
        user = Utility.cleanSQL(user); 

        try{
            stmt = conn.createStatement();
            sql = "SELECT * FROM users WHERE email='" + user + "'";
            rs = stmt.executeQuery(sql);
            if(rs.next()){
                userID = rs.getInt("id");
                email = rs.getString("email");
                hash = rs.getBytes("hash");
                salt = rs.getBytes("salt");
                sessionID = rs.getString("session");
                sendAuth(true);
            }else{
                sendAuth(false);
                return;
            }
        } catch(SQLException e) {}
        
        pass += new String(salt);
        md.update(pass.getBytes());
        digest = md.digest();
        
        sendAuth(Arrays.equals(hash,digest));
    }
    
    public void register()
    {
        
    }

    public void sendAuth(boolean success)
    {
        JSONObject json = new JSONObject();
        if(success){
            System.out.println("Success!");
            cs = ClientStatus.AUTHORIZED;
            json.put("message","auth_success");
            if(sessionID == null){
                if(sessionID == null){
                    sessionID = Utility.runCommand("openssl rand -base64 24");
                    try{
                        String sql = "UPDATE users SET session='" + sessionID + "' WHERE id='" + ((Integer)userID).toString() + "'";
                        stmt.executeUpdate(sql);
                    } catch(SQLException ex) {}
                }
                json.put("session",sessionID);
            }
        }else{
            System.out.println("Failed!");
            json.put("message","auth_failed");
        }
        network.sendJSONObject(json,false);
    }
    
    public void closeConnection()
    {
        network.closeConnections();
    }
}
