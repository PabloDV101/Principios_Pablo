import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Class DatabaseConnection
 */
public class DatabaseConnection {

  //
  // Fields
  //

  private static DatabaseConnection instance;
  private static Connection connection;
  private static String URL = "jdbc:mysql://localhost:3306/mi_base";
  private static String USER="pablodev";
  private static String PASSWORD = "pablo";
  
  //
  // Constructors
  //
  private DatabaseConnection () { 
  try{
	connection = DriverManager.getConnection(URL,USER,PASSWORD);
	System.out.println("conexión establecida");

  }catch(SQLException e){
	throw new RuntimeException("Error al conectar a la base de datos: ",e);
  }
  }
 public static DatabaseConnection getInstance(){
if(instance == null){
	instance = new DatabaseConnection();

 }
return instance;
 }
  

  /**
   * Get the value of connection
   * @return the value of connection
   */
  public Connection getConnection () {
    return connection;
  
  }
}
