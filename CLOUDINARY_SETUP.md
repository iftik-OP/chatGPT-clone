# Cloudinary Setup Guide

This app uses Cloudinary to store uploaded images in the cloud instead of locally, with automatic image compression for optimal performance.

## 1. Create a Cloudinary Account

1. Go to [Cloudinary](https://cloudinary.com/) and sign up for a free account
2. After signing up, you'll get your Cloud Name from the dashboard

## 2. Configure Upload Preset

1. In your Cloudinary dashboard, go to **Settings** > **Upload**
2. Scroll down to **Upload presets**
3. Click **Add upload preset**
4. Set the following:
   - **Preset name**: `ml_default` (or any name you prefer)
   - **Signing Mode**: `Unsigned`
   - **Folder**: `chatgpt-clone` (optional, for organization)
5. Click **Save**

## 3. Environment Variables

Create a `.env` file in the root of your project with the following variables:

```env
# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your_cloud_name_here
CLOUDINARY_UPLOAD_PRESET=your_upload_preset_name_here

# MongoDB Configuration (if needed)
MONGODB_URI=mongodb://10.0.2.2:27017/config
MONGODB_DATABASE=config

# OpenAI Configuration (if needed)
OPENAI_API_KEY=your_openai_api_key_here
```

## 4. Features

### ✅ **Cloud Storage**
- Images are automatically uploaded to Cloudinary when selected
- Cloud URLs are stored in MongoDB instead of local file paths
- Images are accessible from anywhere, not just the local device

### ✅ **Smart Image Compression**
- **Automatic Compression**: Images are compressed before upload based on file size
- **Smart Settings**: 
  - Files > 5MB: 800x800px, 70% quality
  - Files > 2MB: 1024x1024px, 80% quality
  - Files > 1MB: 1200x1200px, 85% quality
  - Files < 1MB: 1600x1600px, 90% quality
- **Aspect Ratio Preservation**: Images maintain their original proportions
- **Bandwidth Optimization**: Significantly reduced upload times and storage costs

### ✅ **Fallback Support**
- If Cloudinary upload fails, the app falls back to local storage
- Legacy local images are still supported
- Graceful error handling with user feedback

### ✅ **Performance**
- Images load faster from CDN
- Reduced local storage usage
- Better scalability for multiple users
- Optimized upload speeds with compression

### ✅ **Security**
- Images are stored securely in the cloud
- No sensitive data stored locally
- Automatic backup and redundancy

## 5. Usage

1. **Upload Image**: When you select an image, it's automatically compressed and uploaded to Cloudinary
2. **View Images**: Images are displayed from cloud URLs with loading indicators
3. **Save Conversations**: Cloud image URLs are saved in MongoDB with the conversation
4. **Load Conversations**: Images are loaded from cloud URLs when viewing past conversations

## 6. Image Compression Details

### **Compression Process**
1. **Analysis**: Image file size is analyzed to determine optimal compression settings
2. **Resizing**: Image is resized while maintaining aspect ratio
3. **Quality Reduction**: JPEG quality is adjusted based on file size
4. **Upload**: Compressed image is uploaded to Cloudinary
5. **Cleanup**: Temporary compressed files are automatically cleaned up

### **Compression Benefits**
- **Faster Uploads**: Smaller file sizes mean faster upload times
- **Reduced Bandwidth**: Less data transfer, especially important on mobile networks
- **Lower Storage Costs**: Smaller files use less cloud storage
- **Better Performance**: Faster loading times for users viewing images

### **Quality vs Size Trade-offs**
- **Large Files (>5MB)**: Aggressive compression for maximum bandwidth savings
- **Medium Files (1-5MB)**: Balanced compression for good quality and reasonable size
- **Small Files (<1MB)**: Minimal compression to preserve quality

## 7. Troubleshooting

### Image Upload Fails
- Check your Cloudinary credentials in `.env`
- Verify your upload preset is set to "Unsigned"
- Check internet connection
- Review Cloudinary dashboard for any errors
- Check console logs for compression errors

### Images Don't Load
- Check if the cloud URL is valid
- Verify Cloudinary account is active
- Check network connectivity
- Ensure image compression completed successfully

### Compression Issues
- Check if the `image` package is properly installed
- Verify temporary directory permissions
- Review console logs for compression errors
- Large images may take longer to compress

### Configuration Issues
- Ensure `.env` file is in the project root
- Restart the app after changing environment variables
- Check console logs for configuration warnings

## 8. Default Configuration

If no environment variables are set, the app uses these defaults:
- **Cloud Name**: `dmouqqpu3`
- **Upload Preset**: `ml_default`

⚠️ **Note**: Using default configuration may not work for production. Set up your own Cloudinary account for best results.

## 9. Performance Monitoring

The app provides detailed logging for monitoring:
- `[ImageCompression]` logs show compression progress and results
- `[Cloudinary]` logs show upload status and URLs
- File size comparisons show compression ratios
- Error logs help identify issues quickly

## 10. Advanced Configuration

### Custom Compression Settings
You can modify compression settings in `ImageCompressionService`:
- Adjust maximum dimensions for different file sizes
- Change quality settings for different use cases
- Add custom compression algorithms

### Cloudinary Transformations
Cloudinary supports additional transformations:
- Automatic format conversion (WebP, AVIF)
- Responsive images with different sizes
- Watermarking and overlays
- Advanced optimization settings 