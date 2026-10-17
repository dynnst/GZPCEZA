namespace gzpegm.Models.ViewModels
{
    public class MessageResult
    {
        public bool Success { get; set; }
        public int MessageId { get; set; }
        public string Message { get; set; }
        public string ErrorMessage { get; set; }

        public static MessageResult SuccessResult(int messageId, string message = "İşlem başarılı")
        {
            return new MessageResult
            {
                Success = true,
                MessageId = messageId,
                Message = message
            };
        }

        public static MessageResult ErrorResult(string errorMessage)
        {
            return new MessageResult
            {
                Success = false,
                ErrorMessage = errorMessage
            };
        }
    }
}
