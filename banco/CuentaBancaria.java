

/**
 * Class CuentaBancaria
 */
public class CuentaBancaria {

  //
  // Fields
  //

  private double saldo;
  
  //
  // Constructors
  //
  public CuentaBancaria () { };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

  /**
   * Set the value of saldo
   * @param newVar the new value of saldo
   */
  public void setSaldo (double newVar) {
    saldo = newVar;
  }

  /**
   * Get the value of saldo
   * @return the value of saldo
   */
  public double getSaldo () {
    return saldo;
  }

  //
  // Other methods
  //

  /**
   * @param        saldo
   */
  public CuentaBancaria(double saldo)
  {
	  this.saldo=saldo;
	  System.out.println("Saldo inicial: "+saldo);
  }


  /**
   * @param        cantidad
   */
  public void depositar(double cantidad)
  {
	  saldo += cantidad;
	  System.out.println("deposito: "+cantidad);


  }


  /**
   * @param        cantidad
   */
  public void retirar(double cantidad)
  {
	  System.out.println("retirando: "+cantidad);
	  if(cantidad <= saldo){
		System.out.println("retiro: "+cantidad);
		saldo -= cantidad;
	  }else{
		System.out.println("Saldo insuficiente");
	  }


  }


}
