

/**
 * Class Persona
 */
public class Persona {

  //
  // Fields
  //

  public String nombre;
  public int edad;
  public String sexo;
  
  //
  // Constructors
  //
  public Persona(String nombre, int edad, String sexo) {
 this.nombre=nombre;
 this.edad=edad;
 this.sexo=sexo;
  };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

  /**
   * Set the value of nombre
   * @param newVar the new value of nombre
   */
  public void setNombre (String newVar) {
    nombre = newVar;
  }

  /**
   * Get the value of nombre
   * @return the value of nombre
   */
  public String getNombre () {
    return nombre;
  }

  /**
   * Set the value of edad
   * @param newVar the new value of edad
   */
  public void setEdad (int newVar) {
    edad = newVar;
  }

  /**
   * Get the value of edad
   * @return the value of edad
   */
  public int getEdad () {
    return edad;
  }

  /**
   * Set the value of sexo
   * @param newVar the new value of sexo
   */
  public void setSexo (String newVar) {
    sexo = newVar;
  }

  /**
   * Get the value of sexo
   * @return the value of sexo
   */
  public String getSexo () {
    return sexo;
  }

  //
  // Other methods
  //

  /**
   * @param        nombre
   * @param        edad
   * @param        sexo
   */
  public void mostrarDatos(String nombre, int edad, String sexo)
  {
	  System.out.println("Nombre: "+nombre);
	  System.out.println("Edad: "+edad);
	  System.out.println("Sexo: "+sexo);

  }


}
