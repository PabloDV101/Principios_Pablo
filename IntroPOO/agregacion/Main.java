import java.util.ArrayList;
import java.util.List;
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
  public static void main(String args [])
  {
	  Profesor p1 = new Profesor("adsoftsito","principios");
	  Profesor p2 = new Profesor("gabriel","IA");

	  List<Profesor> profesores = new ArrayList<>();
	  profesores.add(p1);
	  profesores.add(p2);

	  Universidad uni = new Universidad("USBI",profesores);

	  uni.mostrarProfesores();
  }


}
