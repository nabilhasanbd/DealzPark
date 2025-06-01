using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DealzParkApi.Models
{
    
    public class Offer
    {
        public int Id { get; set; }

        [Required]
        [MaxLength(200)]
        public string PromotionalTitle { get; set; }

        public string? PromotionalImageUrl { get; set; } // Optional

        [Range(0, 100)]
        public int DiscountPercentage { get; set; }

        public string? ProductImageUrl { get; set; } // Optional

        [Required]
        public DateTime ValidFrom { get; set; }

        [Required]
        public DateTime ValidTo { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Required]
        [MaxLength(100)]
        public string Category { get; set; }

        // Foreign Key for Shop
        public int ShopId { get; set; }

        // Navigation property
        [ForeignKey("ShopId")]
        public virtual Shop? Shop { get; set; }
    }
}