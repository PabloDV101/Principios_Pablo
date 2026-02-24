

/**
 * Class Automovil
 */
public class Automovil {

  //
  // Fields
  //

  private String modelo;
  private final Motor motor;
  
  //
  // Constructors
  //
  public Automovil (String modelo, String tipoMotor) {
 this.modelo=modelo;
 this.motor = new Motor(tipoMotor);
  };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

  /**
   * Get the value of motor
   * @return the value of motor
   */
  public Motor getMotor () {
    return motor;
  }

 

  //
  // Other methods
  //

  /**
   */
  public void arrancar()
  {
	  System.out.println("Arrancando el modelo: "+modelo);
	  motor.encender();
  }


}
