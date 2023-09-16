import '../../return_success_or_error.dart';

///Abstração da camada de apresentação quando tem necessidade de exportar apenas
///o resultado final do caso de uso. Nessa camada o caso de uso é instanciado,
///juntamente com o datasource caso exista, e o resultado pode ser exportado diretamente.
abstract interface class Presenter<TypeUsecase> {
  Future<ReturnSuccessOrError<TypeUsecase>> call(
    covariant ParametersReturnResult parameters,
  );
}
