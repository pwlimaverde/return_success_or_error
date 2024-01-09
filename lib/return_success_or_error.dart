library return_success_or_error;

///Responsible for exposing the abstraction of the datasource.
///
///The ´´´Datasource´´´ is the class responsible for querying the external call. And
///must return the type of the pre-defined data or an AppError which is an
///Exeption.
export 'src/interfaces/datasource.dart';

///Abstraction of the presentation layer when you only need to export
///the end result of the use case. In this layer the use case is instantiated,
///along with the datasource if it exists, and the result can be exported directly.
export 'src/interfaces/presenter.dart';

///Responsible for exposing the abstraction of the errors.
///
///The classes that represented the errors need to implement the AppError class
///and override the ´´´message´´´ parameter
export 'src/interfaces/errors.dart';

///Responsible for exposing the abstraction of the parameters.
///
///The parameter class is responsible for storing and handling the parameters
///that need to be received by the datasource. in the implementation you need
///to override the error parameter, which needs to receive an AppError, and
///will be returned in case of failure.
export 'src/core/parameters.dart';

///Responsible for exposing the abstraction of the runtime_milliseconds.
///
///Auxiliary class that allows the observation of the time it took for the
///presenter to process the response.
export 'src/core/runtime_milliseconds.dart';

///Responsible for exposing the abstraction of the return_success_or_error.
///
///the ReturnSuccessOrError class stores 2 types of data. SuccessReturn and
///ErrorReturn which in turn stores the result in case of success or an
///AppError in case of failure.
export 'src/core/return_success_or_error.dart';

//Responsible for the business rule
///
///Base class responsible for accessing and processing the datasource and
///building the feature's business rule
export 'src/bases/usecase_base.dart';
