

/**
 * Class Main
 */
public class Main {

  //
  // Fields
  //

  
  //
  // Constructors
  //
  public Main () { };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

  //
  // Other methods
  //

  /**
   * @param        args_
   */
  public static void main(String args[])
  {
	  CuentaBancaria cuenta1 = new CuentaBancaria(1000);
	  cuenta1.depositar(500);
	  cuenta1.retirar(1500);
	  System.out.println("saldo actual: "+cuenta1.getSaldo());
	  cuenta1.retirar(100);

  }


}
