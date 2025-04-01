using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

namespace Elearning.Api.Middleware;

internal sealed class GlobalExceptionHandler(ILogger<GlobalExceptionHandler> logger) : IExceptionHandler
{
  public async ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
  {
    logger.LogError(exception, "Unhandled exeception occurred");
    var problemDetails = new ProblemDetails
    {
      Status = StatusCodes.Status500InternalServerError,
      Type = "",
      Title = "Server failure"
    };
    httpContext.Response.StatusCode = problemDetails.Status.Value;

    await httpContext.Response.WriteAsJsonAsync(problemDetails, cancellationToken);
    return true;
  }
}