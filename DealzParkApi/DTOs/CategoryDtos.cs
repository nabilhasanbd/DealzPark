using System.ComponentModel.DataAnnotations;

namespace DealzParkApi.DTOs
{
    public class CategoryCreationDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; }
    }

    // You might also want a CategoryResponseDto if it differs from the model,
    // but for now, returning the Category model itself is fine.
}