import java.sql.Connection;


/**
 * Class Main
 */
public class Main {


  public static void main(String args[])
  {
	Connection conn1 = DatabaseConnection.getInstance().getConnection();
	Connection conn2 = DatabaseConnection.getInstance().getConnection();

	System.out.println(conn1==conn2);
  }


}
